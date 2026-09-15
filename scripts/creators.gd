extends Control

const UI := preload("res://scripts/ui_style.gd")
const MEMBER_NAMES := ["Elinéia Rita\nBassani", "Lucas Ferreira\nGritti Campanharo", "Luís Miguel\nJacobus", "Sanny\nBelisário"]
var title: Label
var cards: Array[Panel] = []
var back_button: TextureButton

func _ready() -> void:
	title = UI.label("Criadores", 44)
	add_child(title)
	for member in MEMBER_NAMES:
		var card := Panel.new()
		card.add_theme_stylebox_override("panel", UI.box(UI.PANEL, 32))
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(card)
		var name_label := UI.label(member, 34)
		name_label.add_theme_constant_override("line_spacing", -6)
		card.add_child(name_label)
		name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		cards.append(card)
	back_button = UI.back(_on_back_pressed)
	add_child(back_button)
	resized.connect(_layout)
	_layout()

func _layout() -> void:
	UI.place(title, Rect2(0, 245, 720, 85), size)
	for i in cards.size():
		UI.place(cards[i], Rect2(170, 445 + i * 205, 380, 144), size)
	UI.place_back(back_button, size)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
