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
		Color("8D1A2D"),
		Color("EF3E1B")
	],

	[
		Color("083B00"),
		Color("28620F")
	],

	[
		Color("FF80C0"),
		Color("FFE183")
	],

	[
		Color("A8B37C"),
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
		Color("300700"),
		Color("750D00"),
		Color("B8200C"),
		Color("F04A17")
	],

	[
		Color("68E6DD"),
		Color("2AC4B6"),
		Color("FFF18C"),
		Color("FFB86C")
	],

	[
		Color("E48727"),
		Color("F7CB55"),
		Color("FFF091"),
		Color("ADE0EE")
	]
]

var selected_palette := 8


func get_rows() -> int:
	return int(selected_pattern.split("×")[0])


func get_columns() -> int:
	return int(selected_pattern.split("×")[1])


func get_colors() -> Array:
	return COLOR_PALETTES[selected_palette].duplicate()
