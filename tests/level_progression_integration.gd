extends SceneTree

# Execute com: godot --headless --path . --script tests/level_progression_integration.gd
var failures := 0
var transitions := 0


func _initialize() -> void:
	scene_changed.connect(func(): transitions += 1)
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func open_level(number: int) -> void:
	change_scene_to_file("res://scenes/level_%d.tscn" % number)
	await scene_changed


func buttons() -> Array[Node]:
	return current_scene.overlay.find_children("*", "Button", true, false)


func clear_level() -> void:
	var level = current_scene
	var bricks := get_nodes_in_group("bricks")
	var total := bricks.size()
	for i in total - 1:
		bricks[i].hit()
	check(not level.game_over and not level.overlay.visible, "Encerrou antes do último bloco")
	check(level.bricks_remaining == 1, "Contagem antes do último bloco incorreta")
	bricks[-1].hit()
	check(level.game_over and level.bricks_remaining == 0, "Último bloco não encerrou a fase")
	check(level.bricks_destroyed == total, "Contagem final incorreta")
	check(not level.ball.launched and not level.ball.is_physics_processing(), "Bola permaneceu ativa")
	check(not level.paddle.is_physics_processing() and not level.paddle.is_processing_unhandled_input(), "Raquete permaneceu ativa")
	bricks[-1].hit()
	level._on_brick_destroyed(bricks[-1])
	level._on_ball_hit_brick(bricks[-1])
	level.ball.missed.emit()
	check(level.bricks_destroyed == total and level.bricks_remaining == 0, "Sinais repetidos alteraram o encerramento")


func check_fresh_level(number: int) -> void:
	check(current_scene.name == "Level%d" % number, "Destino incorreto")
	check(not current_scene.game_over and not current_scene.overlay.visible, "Nova fase já encerrada")
	check(current_scene.bricks_remaining == get_nodes_in_group("bricks").size(), "Blocos não foram reiniciados")
	check(current_scene.bricks_destroyed == 0 and not current_scene.ball.launched, "Nova fase não aguarda lançamento")


func _run() -> void:
	# Limita a execução para que uma transição ausente não deixe o teste pendurado.
	create_timer(20.0).timeout.connect(func():
		push_error("Tempo limite aguardando progressão")
		quit(1)
	)
	var settings = root.get_node("GameSettings")
	settings.selected_pattern = "3×5"
	settings.selected_palette = 3
	await open_level(1)
	for number in range(1, 5):
		check_fresh_level(number)
		var before := transitions
		clear_level()
		check(not current_scene.overlay.visible, "Vitória intermediária mostrou painel")
		await scene_changed
		await process_frame
		check(transitions == before + 1, "Vitória provocou transições duplicadas")
	check_fresh_level(5)
	clear_level()
	await process_frame
	await process_frame
	check(current_scene.name == "Level5" and current_scene.overlay.visible, "Conclusão não manteve painel final")
	check(current_scene.end_title.text == "Jogo concluído!", "Título final incorreto")
	check(buttons().size() == 2 and buttons()[0].text == "Começar de novo" and buttons()[1].text == "Sair", "Ações finais incorretas")
	buttons()[0].pressed.emit()
	await scene_changed
	check_fresh_level(1)
	check(current_scene.bricks_remaining == 15, "Reinício não restaurou todos os blocos")
	check(settings.selected_pattern == "3×5" and settings.selected_palette == 3, "Preferências foram alteradas")

	for number in range(1, 6):
		await open_level(number)
		var brick = get_nodes_in_group("bricks")[0]
		brick.hit()
		current_scene.ball.missed.emit()
		check(current_scene.overlay.visible and current_scene.destroyed_count_label.text == "1", "Derrota não mostrou resultado")
		check(buttons().size() == (3 if number < 5 else 2), "Opções de derrota alteradas")
		check(buttons()[0].text == "Jogar novamente", "Derrota ofereceu reinício do jogo")
		buttons()[0].pressed.emit()
		await scene_changed
		check_fresh_level(number)
		current_scene.ball.missed.emit()
		if number < 5:
			buttons()[1].pressed.emit()
			await scene_changed
			check_fresh_level(number + 1)
			current_scene.ball.missed.emit()
		buttons()[-1].pressed.emit()
		await scene_changed
		check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Sair após derrota não voltou ao menu")

	await open_level(5)
	clear_level()
	await process_frame
	buttons()[1].pressed.emit()
	await scene_changed
	check(current_scene.scene_file_path == "res://scenes/main_menu.tscn", "Sair após vitória não voltou ao menu")
	print("Level progression integration: falhas: ", failures)
	quit(1 if failures else 0)
