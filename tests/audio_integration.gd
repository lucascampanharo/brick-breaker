extends SceneTree

# Execute com: godot --headless --path . --script tests/audio_integration.gd
var failures := 0
var audio: Node


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func stop_sounds() -> void:
	for player in audio.get_children():
		player.stop()


func check_sound(expected: AudioStreamPlayer) -> void:
	for player in audio.get_children():
		check(player.playing == (player == expected), "Efeito incorreto: " + player.stream.resource_path)


func _run() -> void:
	create_timer(15).timeout.connect(func():
		push_error("Tempo limite no teste de áudio")
		quit(1)
	)
	audio = root.get_node("GameAudio")
	for player in audio.get_children():
		check(player.volume_db == -12 and player.max_polyphony == 4, "Volume/polifonia incorretos")
		check(player.stream.format == AudioStreamWAV.FORMAT_16_BITS, "Efeito deve usar PCM sem compressão")
		check(player.stream.get_length() >= 0.06 and player.stream.get_length() <= 0.181, "Duração incorreta")

	change_scene_to_file("res://scenes/level_1.tscn")
	await scene_changed
	check_sound(null)
	var ball = current_scene.ball
	ball.set_physics_process(false)
	ball.launch()
	check_sound(audio.launch_player)
	stop_sounds()
	ball.launch()
	check_sound(null)
	ball.reset(ball.position)
	check_sound(null)
	ball.launch()
	check_sound(audio.launch_player)
	stop_sounds()

	# Colisão real com a raquete, sem avançar a física automaticamente.
	ball.position = current_scene.paddle.position + Vector2(0, -40)
	ball.velocity = Vector2(0, 480)
	await physics_frame
	ball._physics_process(0.1)
	check(ball.velocity.y < 0, "Não colidiu com paddle")
	check_sound(audio.paddle_player)
	stop_sounds()

	# Teto e lateral não disparam os efeitos de impacto.
	for scenario in [
		[Vector2(360, 30), Vector2(0, -480)],
		[Vector2(30, 900), Vector2(-480, 0)],
	]:
		ball.position = scenario[0]
		ball.velocity = scenario[1]
		ball._physics_process(0.1)
		check_sound(null)

	# Remove os demais blocos; o último precisa ser atingido pela física.
	var bricks := get_nodes_in_group("bricks")
	var last = bricks[0]
	for i in range(1, bricks.size()):
		bricks[i].hit()
	await physics_frame
	ball.position = last.position + Vector2(0, last.brick_size.y / 2 + ball.radius + 6)
	ball.velocity = Vector2(0, -480)
	var finished := [false]
	audio.brick_player.finished.connect(func(): finished[0] = true, CONNECT_ONE_SHOT)
	ball._physics_process(0.05)
	check(current_scene.game_over, "Último impacto não encerrou a fase")
	check_sound(audio.brick_player)
	var player_id: int = audio.brick_player.get_instance_id()
	await scene_changed
	check(current_scene.name == "Level2", "Não avançou de fase")
	check(audio.brick_player.get_instance_id() == player_id, "Troca de fase substituiu o player")
	check(audio.brick_player.playing or finished[0], "Troca de fase cortou o áudio antes do término natural")
	if not finished[0]:
		await audio.brick_player.finished
	check(finished[0], "Impacto não terminou naturalmente")
	check_sound(null)

	current_scene._restart_level()
	await scene_changed
	check_sound(null)
	current_scene.ball.launch()
	check_sound(audio.launch_player)
	await create_timer(0.25).timeout
	print("Audio integration: lançamento, colisões e troca de fase; falhas: ", failures)
	quit(1 if failures else 0)
