extends CharacterBody2D

const SPEED := 700.0
const COLOR := Color("76ABAE")

var half_width := 70.0
var min_x := 0.0
var max_x := 720.0
var paddle_size := Vector2(140, 28)


func setup(size: Vector2, screen_width: float, wall_margin: float) -> void:
	paddle_size = size
	half_width = size.x / 2.0
	min_x = wall_margin + half_width
	max_x = screen_width - wall_margin - half_width

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	add_to_group("paddle")

	# A plataforma nunca deve ser empurrada por outros corpos (ex.: a bola);
	# sua posição é controlada só pelo input e pelo clamp abaixo.
	collision_mask = 0

	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-paddle_size / 2.0, paddle_size), COLOR)


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	position.x += direction * SPEED * delta
	position.x = clamp(position.x, min_x, max_x)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		position.x = clamp(event.position.x, min_x, max_x)
	elif event is InputEventScreenDrag:
		position.x = clamp(event.position.x, min_x, max_x)
	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		position.x = clamp(event.position.x, min_x, max_x)
