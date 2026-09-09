extends StaticBody2D

signal destroyed(brick)

var brick_size := Vector2(88, 34)
var brick_color := Color.WHITE


func setup(size: Vector2, color: Color) -> void:
	brick_size = size
	brick_color = color

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

	add_to_group("bricks")
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-brick_size / 2.0, brick_size), brick_color)


func hit() -> void:
	destroyed.emit(self)
	queue_free()
