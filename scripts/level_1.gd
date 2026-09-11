extends Node2D

const BALL_SCRIPT := preload("res://scripts/ball.gd")
const PADDLE_SCRIPT := preload("res://scripts/paddle.gd")
const BRICK_SCRIPT := preload("res://scripts/brick.gd")

const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

const SCREEN_SIZE := Vector2(720, 1280)

const COLOR_HUD_TEXT := Color("76ABAE")
const COLOR_BACKGROUND_DIM := Color(0, 0, 0, 0.1)

const COLOR_PANEL_BG := Color("2B2F3A")
const COLOR_PANEL_TEXT := Color("EEEEEE")
const COLOR_PILL := Color("5FA8A5")
const COLOR_PILL_HOVER := Color("4C8D8A")
const COLOR_PILL_PRESSED := Color("3B706E")

const BRICK_ROWS := 6
const BRICK_COLS := 7
const BRICK_SIZE := Vector2(88, 34)
const BRICK_GAP := Vector2(8, 8)
const BRICK_TOP_MARGIN := 160.0

const BRICK_ROW_COLORS := [
	Color("EF5350"),
	Color("FFA726"),
	Color("FFEE58"),
	Color("66BB6A"),
	Color("42A5F5"),
	Color("AB47BC"),
]

# Matriz de dados da parede: 1 = bloco ativo (visível), 0 = espaço vazio.
const BRICK_LAYOUT := [
	[1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1],
]

const WALL_THICKNESS := 24.0
const PADDLE_SIZE := Vector2(140, 28)
const PADDLE_Y := 1180.0
const BALL_RADIUS := 10.0
const STARTING_LIVES := 3

var lives := STARTING_LIVES
var score := 0
var bricks_remaining := 0
var bricks_destroyed := 0
var game_over := false

var ball: CharacterBody2D
var paddle: CharacterBody2D

var score_label: Label
var lives_label: Label
var destroyed_count_label: Label
var overlay: CenterContainer


func _ready() -> void:
	# A imagem de fundo em si já vem do autoload AppBackground, igual à tela
	# inicial; aqui só escurecemos um pouco para dar contraste à fase.
	_build_background_dim()
	_build_walls()
	_build_bricks()
	_build_paddle()
	_build_ball()
	_build_hud()
	_update_hud()


func _build_background_dim() -> void:
	var dim := ColorRect.new()
	dim.color = COLOR_BACKGROUND_DIM
	dim.size = SCREEN_SIZE
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(dim)


func _build_walls() -> void:
	_build_wall(Vector2(SCREEN_SIZE.x, WALL_THICKNESS), Vector2(SCREEN_SIZE.x / 2.0, -WALL_THICKNESS / 2.0))
	_build_wall(Vector2(WALL_THICKNESS, SCREEN_SIZE.y), Vector2(-WALL_THICKNESS / 2.0, SCREEN_SIZE.y / 2.0))
	_build_wall(Vector2(WALL_THICKNESS, SCREEN_SIZE.y), Vector2(SCREEN_SIZE.x + WALL_THICKNESS / 2.0, SCREEN_SIZE.y / 2.0))


func _build_wall(size: Vector2, center: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = center

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	wall.add_child(collision)

	add_child(wall)


func _build_bricks() -> void:
	bricks_remaining = 0
	var grid_width := BRICK_COLS * BRICK_SIZE.x + (BRICK_COLS - 1) * BRICK_GAP.x
	var start_x := (SCREEN_SIZE.x - grid_width) / 2.0 + BRICK_SIZE.x / 2.0

	for row in BRICK_ROWS:
		for col in BRICK_COLS:
			if BRICK_LAYOUT[row][col] == 0:
				continue

			var brick := StaticBody2D.new()
			brick.set_script(BRICK_SCRIPT)
			brick.position = Vector2(
				start_x + col * (BRICK_SIZE.x + BRICK_GAP.x),
				BRICK_TOP_MARGIN + row * (BRICK_SIZE.y + BRICK_GAP.y)
			)
			add_child(brick)
			brick.setup(BRICK_SIZE, BRICK_ROW_COLORS[row % BRICK_ROW_COLORS.size()])
			brick.destroyed.connect(_on_brick_destroyed)
			bricks_remaining += 1


func _build_paddle() -> void:
	paddle = CharacterBody2D.new()
	paddle.set_script(PADDLE_SCRIPT)
	paddle.position = Vector2(SCREEN_SIZE.x / 2.0, PADDLE_Y)
	add_child(paddle)
	paddle.setup(PADDLE_SIZE, SCREEN_SIZE.x, WALL_THICKNESS)


func _build_ball() -> void:
	ball = CharacterBody2D.new()
	ball.set_script(BALL_SCRIPT)
	add_child(ball)
	ball.setup(BALL_RADIUS, SCREEN_SIZE)
	ball.follow_target = paddle
	ball.brick_hit.connect(_on_ball_hit_brick)
	ball.missed.connect(_on_ball_missed)
	_reset_ball()


func _reset_ball() -> void:
	ball.reset(paddle.position + Vector2(0, -PADDLE_SIZE.y / 2.0 - BALL_RADIUS - 2.0))


func _build_hud() -> void:
	# A UI precisa estar sob um CanvasLayer (para as âncoras resolverem contra
	# o viewport, já que um Node2D puro não fornece essa área de referência) e
	# usar set_anchors_AND_OFFSETS_preset (set_anchors_preset sozinho só move
	# as âncoras preservando o retângulo atual, que para um Control novo é
	# (0, 0) — o controle nunca chega a esticar para tela cheia).
	var hud_layer := CanvasLayer.new()
	add_child(hud_layer)

	var hud := Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	score_label = Label.new()
	score_label.position = Vector2(24, 24)
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.add_theme_color_override("font_color", COLOR_HUD_TEXT)
	hud.add_child(score_label)

	lives_label = Label.new()
	lives_label.position = Vector2(SCREEN_SIZE.x - 176, 24)
	lives_label.add_theme_font_size_override("font_size", 28)
	lives_label.add_theme_color_override("font_color", COLOR_HUD_TEXT)
	hud.add_child(lives_label)

	overlay = CenterContainer.new()
	overlay.visible = false
	hud.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	overlay.add_child(_build_end_panel())


func _build_end_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_box_style(COLOR_PANEL_BG, 25, 30))

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(297, 0)
	content.add_theme_constant_override("separation", 21)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Blocos destruídos"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	content.add_child(title)

	var count_box := PanelContainer.new()
	count_box.add_theme_stylebox_override("panel", _make_box_style(COLOR_PILL, 19, 13))
	content.add_child(count_box)

	destroyed_count_label = Label.new()
	destroyed_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	destroyed_count_label.add_theme_font_size_override("font_size", 30)
	destroyed_count_label.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	count_box.add_child(destroyed_count_label)

	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 15)
	actions.add_child(_build_pill_button("Jogar novamente", _restart_level))
	actions.add_child(_build_pill_button("Ir para próxima fase", _on_next_level_pressed))
	actions.add_child(_build_pill_button("Sair", _return_to_menu))
	content.add_child(actions)

	return panel


func _build_pill_button(label_text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0, 59)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_PANEL_TEXT)
	button.add_theme_stylebox_override("normal", _make_box_style(COLOR_PILL, 30, 13))
	button.add_theme_stylebox_override("hover", _make_box_style(COLOR_PILL_HOVER, 30, 13))
	button.add_theme_stylebox_override("pressed", _make_box_style(COLOR_PILL_PRESSED, 30, 13))
	button.pressed.connect(callback)
	return button


func _make_box_style(base_color: Color, corner_radius: int, content_padding: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = base_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.content_margin_left = content_padding
	style.content_margin_right = content_padding
	style.content_margin_top = content_padding
	style.content_margin_bottom = content_padding
	return style


func _update_hud() -> void:
	score_label.text = "Pontos: %d" % score
	lives_label.text = "Vidas: %d" % lives


func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if event is InputEventScreenTouch and event.pressed:
		ball.launch()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ball.launch()


func _on_brick_destroyed(_brick) -> void:
	score += 10
	bricks_remaining -= 1
	bricks_destroyed += 1
	_update_hud()
	if bricks_remaining <= 0:
		_finish_level()


func _on_ball_hit_brick(brick) -> void:
	if brick.has_method("hit"):
		brick.hit()


func _on_ball_missed() -> void:
	if game_over:
		return

	lives = max(lives - 1, 0)
	_update_hud()
	if lives <= 0:
		_finish_level()
	else:
		_reset_ball()


func _finish_level() -> void:
	game_over = true
	ball.reset(ball.position)
	ball.set_physics_process(false)
	destroyed_count_label.text = str(bricks_destroyed)
	overlay.visible = true


func _restart_level() -> void:
	get_tree().reload_current_scene()


func _on_next_level_pressed() -> void:
	# Ainda não há uma próxima fase implementada no projeto.
	print("Próxima fase ainda não disponível")


func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
