extends SceneTree

# Headless: geometry and all five levels. Add -- --capture with a GPU renderer
# to save the same scenes at three target resolutions in .godot/layout-captures.
const RESOLUTIONS := [Vector2i(720, 1280), Vector2i(720, 1560), Vector2i(1080, 2340)]
const SCENES := ["main_menu", "settings", "creators", "level_1", "level_2", "level_3", "level_4", "level_5"]
const DEFAULT_COUNTS := [30, 20, 18, 20, 22]
var failures := 0
var captures := false

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _capture(viewport: SubViewport, filename: String) -> void:
	if not captures:
		return
	await RenderingServer.frame_post_draw
	var result := viewport.get_texture().get_image().save_png("res://.godot/layout-captures/" + filename + ".png")
	check(result == OK, "Falha ao salvar captura: " + filename)

func _inside(control: Control, bounds: Rect2) -> bool:
	return bounds.grow(1).encloses(control.get_global_rect())

func _run() -> void:
	captures = "--capture" in OS.get_cmdline_user_args()
	if captures:
		DirAccess.make_dir_recursive_absolute("res://.godot/layout-captures")
	var settings = root.get_node("GameSettings")
	for resolution in RESOLUTIONS:
		var viewport := SubViewport.new()
		viewport.size = resolution
		viewport.size_2d_override = Vector2i(720, roundi(resolution.y * 720.0 / resolution.x))
		viewport.size_2d_override_stretch = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		viewport.world_2d = World2D.new()
		root.add_child(viewport)
		var background := CanvasLayer.new()
		background.set_script(load("res://scripts/app_background.gd"))
		viewport.add_child(background)
		var bounds := Rect2(Vector2.ZERO, Vector2(viewport.size_2d_override))
		for scene_name in SCENES:
			settings.selected_pattern = "5×6"
			settings.selected_palette = 8
			var scene = load("res://scenes/" + scene_name + ".tscn").instantiate()
			viewport.add_child(scene)
			await process_frame
			await process_frame
			check(_inside(scene.title, bounds), scene_name + ": título cortado")
			var filename := "%s_%dx%d" % [scene_name, resolution.x, resolution.y]
			if scene_name.begins_with("level_"):
				check(scene.bricks_remaining == DEFAULT_COUNTS[scene.level_number - 1], scene_name + ": distribuição padrão")
				check(scene.screen_size == bounds.size and scene.ball.screen_size == bounds.size, scene_name + ": limites divergentes")
				check(_inside(scene.back_button, bounds), scene_name + ": retorno cortado")
				for brick in scene.brick_nodes:
					check(bounds.encloses(Rect2(brick.position - brick.brick_size / 2, brick.brick_size)), scene_name + ": bloco fora da tela")
				await _capture(viewport, filename)
				scene._finish_level()
				await process_frame
				await process_frame
				check(_inside(scene.end_panel, bounds), scene_name + ": modal fora da tela")
				check(scene.shade.visible and scene.overlay.visible, scene_name + ": fim sem sobreposição")
				check(not scene.ball.is_physics_processing() and not scene.paddle.is_processing_unhandled_input(), scene_name + ": jogo ativo no modal")
				check(scene.end_panel.find_children("*", "Button", true, false).size() == (2 if scene.level_number == 5 else 3), scene_name + ": ações incorretas")
				if scene.level_number == 1:
					await _capture(viewport, filename + "_end")
			elif scene_name == "settings":
				check(scene.pattern_grid.get_child_count() == 20 and scene.color_grid.get_child_count() == 9, "Opções incompletas")
				for button in scene.pattern_grid.get_children():
					check(_inside(button, scene.pattern_panel.get_global_rect()), "Padrão fora do painel")
				for button in scene.color_grid.get_children():
					check(_inside(button, scene.color_panel.get_global_rect()), "Paleta fora do painel")
				check(not scene.pattern_panel.get_global_rect().intersects(scene.color_panel.get_global_rect()), "Painéis sobrepostos")
				await _capture(viewport, filename)
			elif scene_name == "creators":
				for card in scene.cards:
					check(_inside(card, bounds), "Criador fora da tela")
					check(card.get_child(0).get_minimum_size().x <= card.size.x, "Nome de criador cortado")
				check(scene.cards[-1].get_global_rect().end.y < scene.back_button.position.y, "Rodapé sobre criadores")
				await _capture(viewport, filename)
			else:
				for button in scene.buttons:
					check(_inside(button, bounds), "Menu fora da tela")
				await _capture(viewport, filename)
			scene.free()
		# Every selectable grid and palette must remain playable in every level.
		for level_number in range(1, 6):
			for pattern in settings.BLOCK_PATTERNS:
				for palette in settings.COLOR_PALETTES.size():
					settings.selected_pattern = pattern
					settings.selected_palette = palette
					var level = load("res://scenes/level_%d.tscn" % level_number).instantiate()
					viewport.add_child(level)
					check(level.bricks_remaining > 0, "Fase vazia: %d %s" % [level_number, pattern])
					var active := 0
					for row in level.brick_layout:
						active += row.count(1)
					check(active == level.bricks_remaining, "Contador divergente")
					for brick in level.brick_nodes:
						check(brick.brick_color in settings.get_colors(), "Cor fora da paleta")
					level.free()
		# Resizing an active level preserves progress and updates world bounds.
		settings.selected_pattern = "5×6"
		settings.selected_palette = 8
		var resized_level = load("res://scenes/level_1.tscn").instantiate()
		viewport.add_child(resized_level)
		resized_level._on_ball_hit_brick(resized_level.brick_nodes[0])
		await process_frame
		viewport.size_2d_override = Vector2i(720, 1700)
		await process_frame
		check(resized_level.bricks_destroyed == 1 and resized_level.bricks_remaining == 29, "Resize reiniciou progresso")
		check(resized_level.ball.screen_size.y == 1700 and is_equal_approx(resized_level.paddle.position.y, 1538.5), "Resize não atualizou arena")
		resized_level.ball.position = Vector2(100, 1750)
		resized_level.ball.velocity = Vector2(0, 480)
		resized_level.ball.launched = true
		await physics_frame
		await physics_frame
		check(resized_level.game_over and resized_level.destroyed_count_label.text == "1", "Perda após resize incorreta")
		viewport.free()
	print("Layout integration: 3 resoluções, 2700 combinações de fases/configurações; falhas: ", failures)
	quit(1 if failures else 0)