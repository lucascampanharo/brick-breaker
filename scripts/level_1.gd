extends Node2D

const BALL_SCRIPT := preload("res://scripts/ball.gd")
const PADDLE_SCRIPT := preload("res://scripts/paddle.gd")
const BRICK_SCRIPT := preload("res://scripts/brick.gd")

const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"
const LEVEL_2_SCENE_PATH := "res://scenes/level_2.tscn"

const SCREEN_SIZE := Vector2(720, 1280)

const COLOR_BACKGROUND_DIM := Color(0, 0, 0, 0.0)

const COLOR_PANEL_BG := Color("303841")
const COLOR_PANEL_TEXT := Color.WHITE
const COLOR_PILL := Color("76ABAE")
const COLOR_PILL_HOVER := Color("4C8D8A")
const COLOR_PILL_PRESSED := Color("3B706E")

const BRICK_GAP := Vector2(12, 16)
const BRICK_TOP_MARGIN := 296.0
const BRICK_BOTTOM := 776.0
const BRICK_SIDE_MARGIN := 24.0

const WALL_THICKNESS := 24.0
const PADDLE_SIZE := Vector2(240, 14)
const PADDLE_Y := 1155.0
const BALL_RADIUS := 18.0

var bricks_remaining := 0
var bricks_destroyed := 0
var game_over := false

# Matriz de dados da parede: 1 = bloco ativo, 0 = espaço vazio.
var brick_layout: Array[Array] = []

var ball: CharacterBody2D
var paddle: CharacterBody2D

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
	var rows := GameSettings.get_rows()
	var columns := GameSettings.get_columns()
	var colors := GameSettings.get_colors()
	var brick_size := Vector2(
		(SCREEN_SIZE.x - 2.0 * BRICK_SIDE_MARGIN - (columns - 1) * BRICK_GAP.x) / columns,
		(BRICK_BOTTOM - BRICK_TOP_MARGIN - (rows - 1) * BRICK_GAP.y) / rows
	)
	var start_x := BRICK_SIDE_MARGIN + brick_size.x / 2.0
	var start_y := BRICK_TOP_MARGIN + brick_size.y / 2.0

	brick_layout.clear()
	for row in rows:
		var cells: Array[int] = []
		cells.resize(columns)
		cells.fill(1)
		brick_layout.append(cells)

	for row in rows:
		for col in columns:
			if brick_layout[row][col] == 0:
				continue

			var brick := StaticBody2D.new()
			brick.set_script(BRICK_SCRIPT)
			brick.position = Vector2(
				start_x + col * (brick_size.x + BRICK_GAP.x),
				start_y + row * (brick_size.y + BRICK_GAP.y)
			)
			add_child(brick)
			brick.setup(brick_size, colors[(row * columns + col) % colors.size()])
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
	ball.reset(paddle.position + Vector2(0, -PADDLE_SIZE.y / 2.0 - BALL_RADIUS - 12.0))


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

	var title := Label.new()
	title.text = "Fase 1"
	title.position = Vector2(0, 108)
	title.size = Vector2(SCREEN_SIZE.x, 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", COLOR_PILL)
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	font.font_weight = 700
	title.add_theme_font_override("font", font)
	hud.add_child(title)

	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.icon = preload("res://assets/icons/back.svg")
	back_button.expand_icon = true
	back_button.add_theme_constant_override("icon_max_width", 64)
	back_button.tooltip_text = "Voltar ao menu"
	back_button.position = Vector2(44, 1190)
	back_button.size = Vector2(64, 64)
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.mouse_filter = Control.MOUSE_FILTER_STOP
	back_button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	back_button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	back_button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	back_button.pressed.connect(_return_to_menu)
	hud.add_child(back_button)

	overlay = CenterContainer.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	hud.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	overlay.add_child(_build_end_panel())

	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.4)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.move_child(shade, overlay.get_index())
	shade.hide()
	overlay.visibility_changed.connect(func(): shade.visible = overlay.visible)


func _build_end_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_box_style(COLOR_PANEL_BG, 40, 42))

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(360, 0)
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Blocos destruídos"
	var heading_font := SystemFont.new()
	heading_font.font_names = PackedStringArray(["Arial"])
	heading_font.font_weight = 700
	title.add_theme_font_override("font", heading_font)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	content.add_child(title)

	var count_box := PanelContainer.new()
	count_box.add_theme_stylebox_override("panel", _make_box_style(COLOR_PILL, 14, 8))
	content.add_child(count_box)

	destroyed_count_label = Label.new()
	destroyed_count_label.add_theme_font_override("font", heading_font)
	destroyed_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	destroyed_count_label.add_theme_font_size_override("font_size", 30)
	destroyed_count_label.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	count_box.add_child(destroyed_count_label)

	var question := Label.new()
	question.text = "O que deseja fazer?"
	question.hide()
	question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	question.add_theme_font_size_override("font_size", 25)
	question.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	content.add_child(question)

	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 20)
	actions.add_child(_build_pill_button("Jogar novamente", _restart_level))
	actions.add_child(_build_pill_button("Ir para próxima fase", _on_next_level_pressed))
	actions.add_child(_build_pill_button("Sair", _return_to_menu))
	content.add_child(actions)

	return panel


func _build_pill_button(label_text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0, 60)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", COLOR_PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_PANEL_TEXT)
	button.add_theme_stylebox_override("normal", _make_box_style(COLOR_PILL, 14, 10))
	button.add_theme_stylebox_override("hover", _make_box_style(COLOR_PILL_HOVER, 14, 10))
	button.add_theme_stylebox_override("pressed", _make_box_style(COLOR_PILL_PRESSED, 14, 10))
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


func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if event is InputEventScreenTouch and event.pressed:
		ball.launch()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ball.launch()


func _on_brick_destroyed(_brick) -> void:
	if game_over:
		return
	bricks_remaining -= 1
	bricks_destroyed += 1
	if bricks_remaining <= 0:
		_finish_level(true)


func _on_ball_hit_brick(brick) -> void:
	if game_over:
		return
	if brick.has_method("hit"):
		brick.hit()


func _on_ball_missed() -> void:
	_finish_level()


func _finish_level(won: bool = false) -> void:
	if game_over:
		return
	game_over = true
	ball.reset(ball.position)
	ball.set_physics_process(false)
	paddle.set_physics_process(false)
	paddle.set_process_unhandled_input(false)
	if won:
		_on_next_level_pressed.call_deferred()
		return
	destroyed_count_label.text = str(bricks_destroyed)
	overlay.visible = true


func _restart_level() -> void:
	get_tree().reload_current_scene()


func _on_next_level_pressed() -> void:
	# Disponível mesmo após perder: o objetivo é deixar o jogador avançar de
	# fase independentemente do resultado da tentativa atual.
	get_tree().change_scene_to_file(LEVEL_2_SCENE_PATH)


func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
