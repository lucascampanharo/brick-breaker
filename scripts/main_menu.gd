extends Control


const TITLE_TEXT := "Brick Breaker"

const MENU_OPTIONS := [
	"Iniciar",
	"Configurações",
	"Criadores"
]

const LEVEL_1_SCENE_PATH := "res://scenes/level_1.tscn"


# ============================================================
# CORES
# ============================================================

const COLOR_TITLE := Color("76ABAE")

const COLOR_BUTTON_NORMAL := Color("303841")
const COLOR_BUTTON_HOVER := Color("596067")
const COLOR_BUTTON_PRESSED := Color("533483")

const COLOR_BUTTON_TEXT := Color("76ABAE")


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	font.font_weight = 700
	theme = Theme.new()
	theme.default_font = font

	_build_content()


# ============================================================
# CONTEÚDO DO MENU
# ============================================================

func _build_content() -> void:
	var center := CenterContainer.new()
	center.name = "Center"
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var layout := VBoxContainer.new()
	layout.name = "Layout"
	layout.add_theme_constant_override("separation", 48)
	center.add_child(layout)
	layout.add_child(_build_title())
	layout.add_child(_build_menu_buttons())


func _build_title() -> Label:

	var title := Label.new()

	title.name = "Title"

	title.text = TITLE_TEXT

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		54
	)

	title.add_theme_color_override(
		"font_color",
		COLOR_TITLE
	)

	return title


# ============================================================
# BOTÕES DO MENU
# ============================================================

func _build_menu_buttons() -> VBoxContainer:

	var container := VBoxContainer.new()

	container.name = "MenuButtons"

	container.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)

	container.add_theme_constant_override(
		"separation",
		26
	)

	container.size_flags_horizontal = (
		Control.SIZE_SHRINK_CENTER
	)


	var callbacks := [
		_on_start_pressed,
		_on_settings_pressed,
		_on_creators_pressed
	]


	for i in MENU_OPTIONS.size():

		container.add_child(
			_build_menu_button(
				MENU_OPTIONS[i],
				callbacks[i]
			)
		)


	return container


# ============================================================
# CRIA UM BOTÃO
# ============================================================

func _build_menu_button(
	label_text: String,
	callback: Callable
) -> Button:

	var button := Button.new()

	button.text = label_text

	button.custom_minimum_size = Vector2(
		440,
		100
	)

	button.focus_mode = Control.FOCUS_NONE

	button.add_theme_font_size_override(
		"font_size",
		42
	)

	button.add_theme_color_override(
		"font_color",
		COLOR_BUTTON_TEXT
	)

	button.add_theme_color_override(
		"font_hover_color",
		COLOR_BUTTON_TEXT
	)

	button.add_theme_color_override(
		"font_pressed_color",
		COLOR_BUTTON_TEXT
	)


	button.add_theme_stylebox_override(
		"normal",
		_make_button_style(
			COLOR_BUTTON_NORMAL
		)
	)

	button.add_theme_stylebox_override(
		"hover",
		_make_button_style(
			COLOR_BUTTON_HOVER
		)
	)

	button.add_theme_stylebox_override(
		"pressed",
		_make_button_style(
			COLOR_BUTTON_PRESSED
		)
	)


	button.pressed.connect(callback)

	return button


# ============================================================
# ESTILO DOS BOTÕES
# ============================================================

func _make_button_style(
	base_color: Color
) -> StyleBoxFlat:

	var style := StyleBoxFlat.new()

	style.bg_color = base_color

	style.corner_radius_top_left = 50
	style.corner_radius_top_right = 50
	style.corner_radius_bottom_left = 50
	style.corner_radius_bottom_right = 50

	return style


# ============================================================
# INICIAR
# ============================================================

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(LEVEL_1_SCENE_PATH)


# ============================================================
# CONFIGURAÇÕES
# ============================================================

func _on_settings_pressed() -> void:

	print("Abrindo configurações")

	get_tree().change_scene_to_file(
		"res://scenes/settings.tscn"
	)


# ============================================================
# CRIADORES
# ============================================================

func _on_creators_pressed() -> void:
	print("Criadores pressionado")
	get_tree().change_scene_to_file("res://scenes/creators.tscn")
