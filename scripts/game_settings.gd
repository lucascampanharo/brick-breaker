extends Node

# Preferências mantidas apenas durante a sessão do jogo.

const BLOCK_PATTERNS := [
	"3×4", "4×4", "5×4", "6×4", "3×5",
	"4×5", "5×5", "6×5", "3×6", "4×6",
	"5×6", "6×6", "3×7", "4×7", "5×7",
	"6×7", "3×8", "4×8", "5×8", "6×8"
]

var selected_pattern := "5×6"


# ============================================================
# PALETAS DE CORES
# ============================================================

const COLOR_PALETTES := [
	[
		Color("A61E35"),
		Color("F13A1D")
	],

	[
		Color("003B00"),
		Color("286B0A")
	],

	[
		Color("F477B5"),
		Color("FFE18A")
	],

	[
		Color("B8C584"),
		Color("8D7C52"),
		Color("E7A17F")
	],

	[
		Color("652052"),
		Color("B51E4A"),
		Color("E8784D")
	],

	[
		Color("C6D1D8"),
		Color("E5E2D8"),
		Color("75947D")
	],

	[
		Color("32110D"),
		Color("8C0B08"),
		Color("E63114")
	],

	[
		Color("59D9D1"),
		Color("F0EA1D"),
		Color("FFB36A")
	],

	[
		Color("E98921"),
		Color("F5BB29"),
		Color("FFE98C")
	]
]

var selected_palette := 8


func get_rows() -> int:
	return int(selected_pattern.split("×")[0])


func get_columns() -> int:
	return int(selected_pattern.split("×")[1])


func get_colors() -> Array:
	return COLOR_PALETTES[selected_palette].duplicate()
