extends StaticBody2D

signal destroyed(brick)

var brick_size := Vector2(88, 34)
var brick_color := Color.WHITE
var is_destroyed := false
var collision: CollisionShape2D


func setup(size: Vector2, color: Color) -> void:
	brick_size = size
	brick_color = color

	var shape := RectangleShape2D.new()
	shape.size = size
	collision = CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	add_to_group("bricks")
	queue_redraw()


func _draw() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = brick_color
	style.set_corner_radius_all(int(minf(brick_size.x, brick_size.y) * 0.18))
	draw_style_box(style, Rect2(-brick_size / 2.0, brick_size))


func resize_brick(size: Vector2) -> void:
	brick_size = size
	collision.shape.size = size
	queue_redraw()


func hit() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	collision.set_deferred("disabled", true)
	destroyed.emit(self)
	queue_free()
