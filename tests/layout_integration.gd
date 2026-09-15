extends SceneTree

var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func _run() -> void:
	var settings = root.get_node("GameSettings")
	for viewport_size in [Vector2i(720, 1280), Vector2i(720, 1600), Vector2i(1280, 1280)]:
		var viewport := SubViewport.new()
		viewport.size = viewport_size
		root.add_child(viewport)
		for scene_name in ["main_menu", "settings"]:
			var screen = load("res://scenes/%s.tscn" % scene_name).instantiate()
			viewport.add_child(screen)
			for frame in 4:
				await process_frame
			var layout: Control = screen.get_node("Center/Layout")
			var rect := layout.get_global_rect()
			check(rect.get_center().distance_to(Vector2(viewport_size) / 2.0) <= 1.0, "%s: centralizacao %s" % [scene_name, viewport_size])
			check(Rect2(Vector2.ZERO, Vector2(viewport_size)).encloses(rect), "%s: conteudo fora da tela" % scene_name)
			var previous_bottom := rect.position.y
			for child in layout.get_children():
				check(child.get_global_rect().position.y >= previous_bottom, "%s: secoes sobrepostas" % scene_name)
				previous_bottom = child.get_global_rect().end.y
			if scene_name == "settings":
				var back: Control = screen.get_node("BackButton")
				check(back.position.distance_to(Vector2(44, viewport_size.y - 90)) <= 1.0, "Posicao de voltar")
				check(not back.get_global_rect().intersects(rect), "Voltar sobrepoe conteudo")
			screen.free()
		viewport.free()

		for phase in range(1, 6):
			for pattern in settings.BLOCK_PATTERNS:
				settings.selected_pattern = pattern
				var level = load("res://scenes/level_%s.tscn" % phase).instantiate()
				level.SCREEN_SIZE = Vector2(viewport_size)
				root.add_child(level)
				var columns: int = settings.get_columns()
				var rows: int = settings.get_rows()
				var expected_size := Vector2((viewport_size.x - 16.0 - (columns - 1) * 4.0) / columns, (480.0 - (rows - 1) * 4.0) / rows)
				var index := 0
				var bricks := get_nodes_in_group("bricks")
				for row in rows:
					for col in columns:
						if level.brick_layout[row][col] == 0:
							continue
						var brick = bricks[index]
						var expected_position := Vector2(8, 296) + expected_size / 2.0 + Vector2(col, row) * (expected_size + Vector2(4, 4))
						check(brick.position.distance_to(expected_position) < 0.001, "Posicao dos blocos: fase %s, %s" % [phase, pattern])
						check(brick.brick_size.distance_to(expected_size) < 0.001, "Tamanho dos blocos")
						check(brick.collision.shape.size == brick.brick_size, "Colisao e desenho diferentes")
						index += 1
				check(index == bricks.size(), "Desenho da fase incorreto")
				level.free()
	print("Layout integration: 3 proporcoes, 5 fases, todos os padroes; falhas: ", failures)
	quit(0 if failures == 0 else 1)
