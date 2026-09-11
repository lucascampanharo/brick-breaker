extends CharacterBody2D

signal brick_hit(brick)
signal missed

const SPEED := 480.0
const LAUNCH_ANGLE_SPREAD := PI / 4.0
const PADDLE_BOUNCE_ANGLE := PI / 3.0
const COLOR := Color("EEEEEE")

var radius := 10.0
var screen_size := Vector2(720, 1280)
var launched := false
var follow_target: Node2D = null


func setup(ball_radius: float, viewport_size: Vector2) -> void:
	radius = ball_radius
	screen_size = viewport_size

	var shape := CircleShape2D.new()
	shape.radius = radius
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, COLOR)


func launch() -> void:
	if launched:
		return
	launched = true
	var angle := randf_range(-LAUNCH_ANGLE_SPREAD, LAUNCH_ANGLE_SPREAD) - PI / 2.0
	velocity = Vector2(cos(angle), sin(angle)) * SPEED


func reset(start_position: Vector2) -> void:
	launched = false
	velocity = Vector2.ZERO
	position = start_position


func _physics_process(delta: float) -> void:
	if not launched:
		if follow_target:
			position.x = follow_target.position.x
		return

	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("bricks"):
			velocity = velocity.bounce(collision.get_normal())
			brick_hit.emit(collider)
		elif collider and collider.is_in_group("paddle"):
			_bounce_off_paddle(collider)
		else:
			velocity = velocity.bounce(collision.get_normal())

	if position.y - radius > screen_size.y:
		missed.emit()


func _bounce_off_paddle(paddle) -> void:
	var offset: float = (position.x - paddle.position.x) / paddle.half_width
	offset = clamp(offset, -1.0, 1.0)
	var angle: float = offset * PADDLE_BOUNCE_ANGLE - PI / 2.0
	velocity = Vector2(cos(angle), sin(angle)) * SPEED
