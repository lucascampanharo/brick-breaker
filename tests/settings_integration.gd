extends SceneTree

# Execute com: godot --headless --path . --script tests/settings_integration.gd
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _run() -> void:
	var settings = root.get_node("GameSettings")
	check(settings.selected_pattern == "5×6", "Padrão inicial incorreto")
	check(settings.selected_palette == 8, "Paleta inicial incorreta")
	var level_scene = load("res://scenes/level_1.tscn")
	for pattern in settings.BLOCK_PATTERNS:
		settings.selected_pattern = pattern
		for palette_index in settings.COLOR_PALETTES.size():
			settings.selected_palette = palette_index
			var level = level_scene.instantiate()
			root.add_child(level)
			var bricks = get_nodes_in_group("bricks")
			var dimensions = pattern.split("×")
			var rows = int(dimensions[0])
			var columns = int(dimensions[1])
			var palette = settings.COLOR_PALETTES[palette_index]
			check(bricks.size() == rows * columns, "Quantidade incorreta: " + pattern)
			check(level.bricks_remaining == bricks.size(), "Contador inicial incorreto")
			check(level.brick_layout.size() == rows, "Matriz com linhas incorretas")
			for cells in level.brick_layout:
				check(cells.size() == columns and cells.count(1) == columns, "Matriz incompleta")
			for i in bricks.size():
				var brick = bricks[i]
				check(brick.brick_color == palette[i % palette.size()], "Sequência de cores incorreta")
				check(brick.get_child(0).shape.size == brick.brick_size, "Colisão diferente do tamanho visual")
				check(brick.brick_size == bricks[0].brick_size, "Tamanhos diferentes na parede")
				if i % columns == 0:
					check(is_equal_approx(brick.position.x - brick.brick_size.x / 2.0, 12.0), "Margem esquerda incorreta")
				else:
					check(is_equal_approx(brick.position.x - bricks[i - 1].position.x - brick.brick_size.x, 8.0), "Espaçamento horizontal incorreto")
				if i % columns == columns - 1:
					check(is_equal_approx(brick.position.x + brick.brick_size.x / 2.0, 708.0), "Margem direita incorreta")
				if i < columns:
					check(is_equal_approx(brick.position.y - brick.brick_size.y / 2.0, 160.0), "Topo incorreto")
				else:
					check(is_equal_approx(brick.position.y - bricks[i - columns].position.y - brick.brick_size.y, 8.0), "Espaçamento vertical incorreto")
				if i >= (rows - 1) * columns:
					check(is_equal_approx(brick.position.y + brick.brick_size.y / 2.0, 640.0), "Base incorreta")
			check(is_equal_approx(bricks[0].position.x + bricks[columns - 1].position.x, 720.0), "Parede descentralizada")
			level.free()

	change_scene_to_file("res://scenes/main_menu.tscn")
	await scene_changed
	current_scene._on_settings_pressed()
	await scene_changed
	# Aciona os mesmos sinais usados pelos cliques da interface.
	current_scene.pattern_grid.get_child(settings.BLOCK_PATTERNS.find("3×5")).pressed.emit()
	current_scene.color_grid.get_child(3).pressed.emit()
	check(settings.selected_pattern == "3×5" and settings.selected_palette == 3, "Interface não atualizou preferências")
	current_scene._on_back_pressed()
	await scene_changed
	current_scene._on_start_pressed()
	await scene_changed
	check(current_scene.bricks_remaining == 15, "Partida não recebeu preferências")
	await physics_frame
	await physics_frame
	var first_brick = get_nodes_in_group("bricks")[0]
	var query := PhysicsRayQueryParameters2D.create(first_brick.position - Vector2(0, first_brick.brick_size.y / 2.0 + 4.0), first_brick.position)
	var collision = current_scene.get_world_2d().direct_space_state.intersect_ray(query)
	check(collision.get("collider") == first_brick, "Bloco não detectado pela física")
	for brick in get_nodes_in_group("bricks"):
		current_scene._on_ball_hit_brick(brick)
		current_scene._on_ball_hit_brick(brick)
	check(current_scene.score == 150 and current_scene.bricks_destroyed == 15, "Pontuação ou destruição incorreta")
	check(current_scene.bricks_remaining == 0 and current_scene.game_over and current_scene.overlay.visible, "Partida não encerrou")
	current_scene._restart_level()
	await scene_changed
	check(current_scene.bricks_remaining == 15 and current_scene.score == 0 and current_scene.bricks_destroyed == 0 and current_scene.lives == 3, "Reinício incorreto")
	check(get_nodes_in_group("bricks")[0].brick_color == settings.COLOR_PALETTES[3][0], "Reinício perdeu paleta")
	current_scene._return_to_menu()
	await scene_changed
	current_scene._on_settings_pressed()
	await scene_changed
	var selected_button = current_scene.pattern_grid.get_child(settings.BLOCK_PATTERNS.find("3×5"))
	check(selected_button.get_theme_stylebox("normal").border_width_left == 4, "Destaque do padrão não restaurado")
	for i in current_scene.color_grid.get_child_count():
		check(current_scene.color_grid.get_child(i).selected == (i == 3), "Destaque da paleta não restaurado")
	print("Settings integration: 180 combinações e fluxo de cenas; falhas: ", failures)
	quit(1 if failures else 0)
