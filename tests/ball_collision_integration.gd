extends SceneTree

# Execute com: godot --headless --path . --script tests/ball_collision_integration.gd
const BALL_SCRIPT = preload("res://scripts/ball.gd")
const BRICK_SCRIPT = preload("res://scripts/brick.gd")
const STEP := 1.0 / 60.0
var failures := 0
var hit_count := 0
var arena: Node2D
var ball: CharacterBody2D
var targets: Array[StaticBody2D] = []


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)


func make_arena(centers: Array, start: Vector2, incoming: Vector2) -> void:
	hit_count = 0
	targets.clear()
	arena = Node2D.new()
	root.add_child(arena)
	for center in centers:
		var brick := StaticBody2D.new()
		brick.set_script(BRICK_SCRIPT)
		brick.position = center
		arena.add_child(brick)
		brick.setup(Vector2(100, 50), Color.WHITE)
		targets.append(brick)
	ball = CharacterBody2D.new()
	ball.set_script(BALL_SCRIPT)
	arena.add_child(ball)
	ball.setup(10.0, Vector2(720, 1280))
	ball.set_physics_process(false)
	ball.position = start
	ball.velocity = incoming
	ball.launched = true
	ball.brick_hit.connect(func(brick):
		hit_count += 1
		brick.hit()
	)


func step() -> void:
	await physics_frame
	ball._physics_process(STEP)


func wait_for_hit(label: String) -> void:
	for frame in 120:
		await step()
		if hit_count > 0:
			break
	check(hit_count == 1, label + ": deve atingir exatamente um bloco")


func check_bounce(incoming: Vector2, label: String) -> void:
	check(is_equal_approx(ball.velocity.y, -incoming.y), label + ": vertical não invertida")
	check(is_equal_approx(ball.velocity.x, incoming.x), label + ": horizontal alterada")
	check(is_equal_approx(ball.velocity.length(), incoming.length()), label + ": velocidade alterada")


func _run() -> void:
	# Blocos empilhados: o inferior deve proteger o superior após o rebote.
	var incoming := Vector2(0, -480)
	make_arena([Vector2(300, 300), Vector2(300, 358)], Vector2(300, 420), incoming)
	await wait_for_hit("Por baixo")
	check_bounce(incoming, "Por baixo")
	check(not targets[0].is_destroyed and targets[1].is_destroyed, "Destruiu o bloco acima")
	for frame in 12:
		await step()
	check(hit_count == 1 and ball.position.y > 420, "Bola continuou pela parede após impacto inferior")
	arena.free()

	# A bola chega por cima, rebate para o teto e então volta para baixo.
	incoming = Vector2(0, 480)
	make_arena([Vector2(300, 300), Vector2(300, 358)], Vector2(300, 240), incoming)
	var ceiling := StaticBody2D.new()
	ceiling.position = Vector2(360, -12)
	var ceiling_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(720, 24)
	ceiling_shape.shape = rectangle
	ceiling.add_child(ceiling_shape)
	arena.add_child(ceiling)
	await wait_for_hit("Por cima")
	check_bounce(incoming, "Por cima")
	check(targets[0].is_destroyed and not targets[1].is_destroyed, "Destruiu o bloco inferior ao atingir por cima")
	for frame in 120:
		await step()
		if ball.velocity.y > 0:
			break
	check(ball.velocity.y > 0 and ball.position.y < 20, "Bola não voltou para baixo ao atingir teto")
	check(hit_count == 1, "Destruiu outro bloco antes do teto")
	arena.free()

	# Laterais e quinas invertem Y, mesmo com normais horizontais/diagonais.
	var cases := [
		["Lateral esquerda", Vector2(220, 300), Vector2(400, -120)],
		["Lateral direita", Vector2(380, 300), Vector2(-400, 120)],
		["Quina inferior", Vector2(230, 345), Vector2(240, -240)],
		["Quina superior", Vector2(370, 255), Vector2(-240, 240)],
	]
	for scenario in cases:
		make_arena([Vector2(300, 300)], scenario[1], scenario[2])
		await wait_for_hit(scenario[0])
		check_bounce(scenario[2], scenario[0])
		for frame in 4:
			await step()
		check(hit_count == 1, scenario[0] + ": impacto repetido")
		arena.free()

	# Contato simultâneo entre dois blocos separados por 8 pixels.
	make_arena([Vector2(300, 300), Vector2(408, 300)], Vector2(354, 380), Vector2(0, -480))
	await wait_for_hit("Junção")
	check_bounce(Vector2(0, -480), "Junção")
	check(targets[0].is_destroyed != targets[1].is_destroyed, "Junção destruiu os dois blocos")
	for frame in 12:
		await step()
	check(hit_count == 1, "Junção causou uma segunda destruição")
	arena.free()

	# Deslocamento grande para no primeiro impacto, sem atravessar.
	make_arena([Vector2(300, 300), Vector2(300, 358)], Vector2(300, 500), Vector2(0, -480))
	await physics_frame
	ball._physics_process(0.5)
	check(hit_count == 1 and not targets[0].is_destroyed, "Passo longo atravessou o primeiro bloco")
	check(ball.position.y > 390 and ball.velocity.y > 0, "Passo longo não parou no contato")
	arena.free()
	# O áudio pertence ao autoload e termina mesmo após liberar a arena.
	await create_timer(0.2).timeout
	print("Ball collision integration: impactos, teto e junção; falhas: ", failures)
	quit(1 if failures else 0)
