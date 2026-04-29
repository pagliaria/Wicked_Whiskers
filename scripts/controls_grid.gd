extends Node

const FONT = preload("res://assets/fonts/PixelOperator8-Bold.ttf")

const ROWS = [
	# [ Action,           Keyboard,              Controller ]
	["Move",              "W / A / S / D",        "Left Stick / D-Pad"],
	["Interact / Pick up","Enter",                 "A Button"],
	["Submit Order",      "1 - 9",                "B Button"],
	["Cycle Order",       "-",                    "LB / RB"],
	["Pause",             "ESC",                  "Start"],
]

const COL_COLORS = [
	Color(0.92, 0.92, 0.92, 1),  # Action — white
	Color(0.6,  0.9,  1.0,  1),  # Keyboard — light blue
	Color(0.6,  1.0,  0.6,  1),  # Controller — light green
]

const HEADERS = ["ACTION", "KEYBOARD", "CONTROLLER"]
const HEADER_COLOR = Color(1, 0.7, 0.0, 1)

func build(grid: GridContainer, font_size: int = 13) -> void:
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 8)

	# Header row
	for i in 3:
		var lbl = _make_label(HEADERS[i], font_size - 1, HEADER_COLOR)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(lbl)

	# Separator row
	for i in 3:
		var sep = HSeparator.new()
		grid.add_child(sep)

	# Data rows
	for row in ROWS:
		for col in 3:
			var lbl = _make_label(row[col], font_size, COL_COLORS[col])
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			grid.add_child(lbl)

func _make_label(text: String, size: int, color: Color) -> Label:
	var lbl = Label.new()
	lbl.text = text
	lbl.add_theme_font_override("font", FONT)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	return lbl
