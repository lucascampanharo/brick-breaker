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
					check(is_equal_approx(brick.position.x - brick.brick_size.x / 2.0, 24.0), "Margem esquerda incorreta")
				else:
					check(is_equal_approx(brick.position.x - bricks[i - 1].position.x - brick.brick_size.x, 12.0), "Espaçamento horizontal incorreto")
				if i % columns == columns - 1:
					check(is_equal_approx(brick.position.x + brick.brick_size.x / 2.0, 696.0), "Margem direita incorreta")
				if i < columns:
					check(is_equal_approx(brick.position.y - brick.brick_size.y / 2.0, 296.0), "Topo incorreto")
				else:
					check(is_equal_approx(brick.position.y - bricks[i - columns].position.y - brick.brick_size.y, 16.0), "Espaçamento vertical incorreto")
				if i >= (rows - 1) * columns:
					check(is_equal_approx(brick.position.y + brick.brick_size.y / 2.0, 776.0), "Base incorreta")
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
	check(current_scene.bricks_destroyed == 15, "Contagem de destruição incorreta")
	check(current_scene.bricks_remaining == 0 and current_scene.game_over and not current_scene.overlay.visible, "Vitória não iniciou avanço automático")
	await scene_changed
	check(current_scene.name == "Level2" and current_scene.bricks_remaining == 9, "Vitória não avançou com as preferências")
	check(get_nodes_in_group("bricks")[0].brick_color == settings.COLOR_PALETTES[3][0], "Avanço perdeu paleta")
	change_scene_to_file("res://scenes/level_1.tscn")
	await scene_changed
	check(current_scene.bricks_remaining == 15 and current_scene.bricks_destroyed == 0, "Reinício incorreto")
	check(get_nodes_in_group("bricks")[0].brick_color == settings.COLOR_PALETTES[3][0], "Reinício perdeu paleta")
	# A primeira saída pela borda inferior encerra a tentativa, sem reposicionar.
	current_scene._on_ball_hit_brick(get_nodes_in_group("bricks")[0])
	current_scene.ball.position = Vector2(100, 1280 + current_scene.ball.radius + 10)
	current_scene.ball.velocity = Vector2(0, 480)
	current_scene.ball.launched = true
	await physics_frame
	await physics_frame
	check(current_scene.game_over and current_scene.overlay.visible, "Primeira perda não abriu modal")
	check(current_scene.ball.position.y > 1280 and current_scene.ball.velocity == Vector2.ZERO, "Perda reposicionou ou não parou a bola")
	check(current_scene.destroyed_count_label.text == "1", "Modal perdeu contagem")
	check(not current_scene.ball.is_physics_processing() and not current_scene.paddle.is_physics_processing(), "Física não bloqueada")
	check(not current_scene.paddle.is_processing_unhandled_input(), "Entrada do paddle não bloqueada")
	var stopped_position: Vector2 = current_scene.paddle.position
	Input.action_press("ui_right")
	var touch := InputEventScreenTouch.new()
	touch.position = Vector2(100, 1100)
	touch.pressed = true
	root.push_input(touch)
	touch.pressed = false
	root.push_input(touch)
	var drag := InputEventMouseMotion.new()
	drag.position = Vector2(600, 1100)
	drag.button_mask = MOUSE_BUTTON_MASK_LEFT
	root.push_input(drag)
	await physics_frame
	await physics_frame
	Input.action_release("ui_right")
	check(current_scene.paddle.position == stopped_position and not current_scene.ball.launched, "Entrada atravessou modal")
	current_scene.ball.missed.emit()
	check(current_scene.destroyed_count_label.text == "1", "Encerramento repetido alterou contagem")
	var buttons: Array[Node] = current_scene.overlay.find_children("*", "Button", true, false)
	check(buttons.size() == 3, "Modal deve oferecer três ações")
	# "Tentar de novo" reinicia a fase mesmo após a derrota.
	buttons[0].pressed.emit()
	await scene_changed
	check(not current_scene.game_over and not current_scene.overlay.visible, "Reinício manteve modal aberto")
	check(current_scene.bricks_remaining == 15 and current_scene.bricks_destroyed == 0 and not current_scene.ball.launched, "Reinício após perda incorreto")
	check(current_scene.paddle.is_physics_processing() and current_scene.paddle.is_processing_unhandled_input(), "Reinício não restaurou controles")

	# Perde de novo para confirmar que "Próximo nível" segue liberado após a derrota.
	current_scene._on_ball_hit_brick(get_nodes_in_group("bricks")[0])
	current_scene.ball.position = Vector2(100, 1280 + current_scene.ball.radius + 10)
	current_scene.ball.velocity = Vector2(0, 480)
	current_scene.ball.launched = true
	await physics_frame
	await physics_frame
	check(current_scene.game_over and current_scene.overlay.visible, "Segunda derrota não abriu modal")
	buttons = current_scene.overlay.find_children("*", "Button", true, false)
	# Clique real no próximo nível, passando pelo roteamento da interface: deve
	# avançar para a Fase 2 mesmo com a tentativa atual tendo sido perdida.
	await process_frame
	await process_frame
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = buttons[1].get_global_rect().get_center()
	click.pressed = true
	root.push_input(click, true)
	click.pressed = false
	root.push_input(click, true)
	await scene_changed
	check(current_scene.name == "Level2" and current_scene.bricks_remaining == 9, "Próximo nível não avançou após a derrota")

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
