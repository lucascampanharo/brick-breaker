extends Control

const UI := preload("res://scripts/ui_style.gd")
var title: Label
var buttons: Array[Button] = []

func _ready() -> void:
	title = UI.label("Brick Breaker", 44)
	add_child(title)
	var texts := ["Iniciar", "Configurações", "Criadores"]
	var callbacks := [_on_start_pressed, _on_settings_pressed, _on_creators_pressed]
	for i in texts.size():
		var button := UI.button(texts[i], callbacks[i])
		add_child(button)
		buttons.append(button)
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	UI.place(title, Rect2(0, 245, 720, 85), size)
	for i in buttons.size():
		UI.place(buttons[i], Rect2(180, 580 + i * 128, 360, 92), size)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")

func _on_creators_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/creators.tscn")