extends Node2D

const UI := preload("res://scripts/ui_style.gd")
const BALL_SCRIPT := preload("res://scripts/ball.gd")
const PADDLE_SCRIPT := preload("res://scripts/paddle.gd")
const BRICK_SCRIPT := preload("res://scripts/brick.gd")
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"
const BRICK_GAP := Vector2(6, 8)
const BRICK_SIDE_MARGIN := 12.0
const WALL_THICKNESS := 24.0
const PADDLE_SIZE := Vector2(190, 14)
const BALL_RADIUS := 18.0
const REFERENCE_LAYOUTS := {
	3: [[1,1,1,1,1,1], [0,1,1,1,1,0], [0,1,1,1,1,0], [0,0,1,1,0,0], [0,0,1,1,0,0]],
	4: [[1,1,1,1,1,1], [1,1,1,1,1,0], [1,1,1,1,0,0], [1,1,1,0,0,0], [1,1,0,0,0,0]],
	5: [[1,1,1,0,1,1], [1,0,1,1,0,1], [1,1,0,1,1,1], [0,1,1,1,1,0], [1,1,0,1,1,0]]
}
# Color slots in the 5×6 reference, including cells hidden by each level.
const REFERENCE_COLORS := [
	[0,1,2,3,0,1], [2,3,0,1,2,3], [1,2,3,0,1,2],
	[3,0,1,2,3,0], [2,3,0,1,2,3]
]

var level_number := 1
var screen_size := Vector2(720, 1280)
var bricks_remaining := 0
var bricks_destroyed := 0
var game_over := false
var brick_layout: Array[Array] = []
var ball: CharacterBody2D
var paddle: CharacterBody2D
var destroyed_count_label: Label
var overlay: CenterContainer
var end_panel: PanelContainer
var shade: ColorRect
var title: Label
var back_button: TextureButton
var walls: Array[StaticBody2D] = []
var brick_nodes: Array[StaticBody2D] = []
var brick_cells: Array[Vector2i] = []

func _ready() -> void:
	screen_size = get_viewport_rect().size
	_build_walls()
	_build_bricks()
	paddle = CharacterBody2D.new()
	paddle.set_script(PADDLE_SCRIPT)
	paddle.position = Vector2(screen_size.x / 2.0, screen_size.y * 0.905)
	add_child(paddle)
	paddle.setup(PADDLE_SIZE, screen_size.x, WALL_THICKNESS)
	ball = CharacterBody2D.new()
	ball.set_script(BALL_SCRIPT)
	add_child(ball)
	ball.setup(BALL_RADIUS, screen_size)
	ball.follow_target = paddle
	ball.brick_hit.connect(_on_ball_hit_brick)
	ball.missed.connect(_on_ball_missed)
	_reset_ball()
	_build_hud()
	get_viewport().size_changed.connect(_resize)
	_layout_hud()

func _build_walls() -> void:
	for i in 3:
		var wall := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		collision.shape = RectangleShape2D.new()
		wall.add_child(collision)
		add_child(wall)
		walls.append(wall)
	_layout_walls()

func _layout_walls() -> void:
	var sizes := [Vector2(screen_size.x, WALL_THICKNESS), Vector2(WALL_THICKNESS, screen_size.y), Vector2(WALL_THICKNESS, screen_size.y)]
	var centers := [Vector2(screen_size.x / 2.0, -WALL_THICKNESS / 2.0), Vector2(-WALL_THICKNESS / 2.0, screen_size.y / 2.0), Vector2(screen_size.x + WALL_THICKNESS / 2.0, screen_size.y / 2.0)]
	for i in walls.size():
		walls[i].position = centers[i]
		walls[i].get_child(0).shape.size = sizes[i]

func _brick_size() -> Vector2:
	var rows := GameSettings.get_rows()
	var columns := GameSettings.get_columns()
	return Vector2(
		(screen_size.x - 2.0 * BRICK_SIDE_MARGIN - (columns - 1) * BRICK_GAP.x) / columns,
		(screen_size.y * 0.30 - (rows - 1) * BRICK_GAP.y) / rows
	)

func _brick_position(row: int, col: int, dimensions: Vector2) -> Vector2:
	return Vector2(BRICK_SIDE_MARGIN, screen_size.y * 0.235) + dimensions / 2.0 + Vector2(col, row) * (dimensions + BRICK_GAP)

func _build_bricks() -> void:
	var rows := GameSettings.get_rows()
	var columns := GameSettings.get_columns()
	var colors := GameSettings.get_colors()
	var dimensions := _brick_size()
	for row in rows:
		var cells: Array[int] = []
		for col in columns:
			var active := 1
			if level_number == 2 and (col == 1 or col == columns - 2):
				active = 0
			elif REFERENCE_LAYOUTS.has(level_number):
				active = REFERENCE_LAYOUTS[level_number][floori((row + 0.5) * 5 / rows)][floori((col + 0.5) * 6 / columns)]
			cells.append(active)
			if not active:
				continue
			var color_index := (row * columns + col) % colors.size()
			if rows == 5 and columns == 6 and GameSettings.selected_palette == 8:
				color_index = REFERENCE_COLORS[row][col]
				# The staircase reference swaps these two colors on its fourth row.
				if level_number == 4 and row == 3 and col in [1, 2]:
					color_index = 2 - col
			var brick := StaticBody2D.new()
			brick.set_script(BRICK_SCRIPT)
			brick.position = _brick_position(row, col, dimensions)
			add_child(brick)
			brick.setup(dimensions, colors[color_index])
			brick.destroyed.connect(_on_brick_destroyed)
			brick_nodes.append(brick)
			brick_cells.append(Vector2i(col, row))
			bricks_remaining += 1
		brick_layout.append(cells)

func _reset_ball() -> void:
	ball.reset(paddle.position + Vector2(0, -PADDLE_SIZE.y / 2.0 - BALL_RADIUS - 18.0))

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var hud := Control.new()
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title = UI.label("Fase %d" % level_number, 42)
	title.name = "LevelTitle"
	hud.add_child(title)
	back_button = UI.back(_return_to_menu)
	hud.add_child(back_button)
	shade = ColorRect.new()
	shade.name = "EndShade"
	shade.color = Color(0, 0, 0, 0.4)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.hide()
	overlay = CenterContainer.new()
	overlay.name = "EndOverlay"
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.hide()
	end_panel = _build_end_panel()
	overlay.add_child(end_panel)

func _build_end_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UI.box(UI.PANEL, 32, 36))
	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(300, 0)
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)
	var heading := UI.label("Blocos destruídos", 28, Color.WHITE)
	heading.custom_minimum_size.y = 50
	content.add_child(heading)
	var count_box := PanelContainer.new()
	count_box.add_theme_stylebox_override("panel", UI.box(UI.TEXT, 14))
	count_box.custom_minimum_size.y = 58
	content.add_child(count_box)
	destroyed_count_label = UI.label("0", 36, Color.WHITE)
	count_box.add_child(destroyed_count_label)
	var actions := [
		["Jogar novamente", _restart_level],
		["Ir para próxima fase", _on_next_level_pressed],
		["Sair", _return_to_menu]
	]
	for i in actions.size():
		if level_number == 5 and i == 1:
			continue
		var button := UI.button(actions[i][0], actions[i][1], true)
		button.custom_minimum_size.y = 58
		content.add_child(button)
	return panel

func _layout_hud() -> void:
	UI.place(title, Rect2(0, 130, 720, 100), screen_size)
	UI.place_back(back_button, screen_size)

func _resize() -> void:
	var previous_size := screen_size
	screen_size = get_viewport_rect().size
	_layout_walls()
	var dimensions := _brick_size()
	for i in brick_nodes.size():
		if is_instance_valid(brick_nodes[i]):
			var brick := brick_nodes[i]
			brick.position = _brick_position(brick_cells[i].y, brick_cells[i].x, dimensions)
			brick.resize_brick(dimensions)
	paddle.min_x = WALL_THICKNESS + paddle.half_width
	paddle.max_x = screen_size.x - WALL_THICKNESS - paddle.half_width
	paddle.position = Vector2(clampf(paddle.position.x, paddle.min_x, paddle.max_x), screen_size.y * 0.905)
	ball.screen_size = screen_size
	if not game_over:
		if ball.launched:
			ball.position *= screen_size / previous_size
		else:
			_reset_ball()
	_layout_hud()

func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	if event is InputEventScreenTouch and event.pressed:
		ball.launch()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ball.launch()

func _on_brick_destroyed(_brick) -> void:
	bricks_remaining -= 1
	bricks_destroyed += 1
	if bricks_remaining <= 0:
		_finish_level()

func _on_ball_hit_brick(brick) -> void:
	if brick.has_method("hit"):
		brick.hit()

func _on_ball_missed() -> void:
	_finish_level()

func _finish_level() -> void:
	if game_over:
		return
	game_over = true
	ball.reset(ball.position)
	ball.set_physics_process(false)
	paddle.set_physics_process(false)
	paddle.set_process_unhandled_input(false)
	destroyed_count_label.text = str(bricks_destroyed)
	shade.show()
	overlay.show()

func _restart_level() -> void:
	get_tree().reload_current_scene()

func _on_next_level_pressed() -> void:
	if level_number < 5:
		get_tree().change_scene_to_file("res://scenes/level_%d.tscn" % (level_number + 1))

func _return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
