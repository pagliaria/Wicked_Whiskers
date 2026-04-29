extends Control

var order_time
@onready var progress_bar: ProgressBar = $Panel/ProgressBar
@onready var item_number: Label = $Panel/item_number
@onready var happy: TextureRect = $Panel/happy
@onready var angry: TextureRect = $Panel/angry
@onready var surprised: TextureRect = $Panel/surprised
@onready var hat_image: TextureRect = $Panel/hat_image
@onready var panel: Panel = $Panel
@onready var selected_indicator: Label = $SelectedIndicator

const CAP = preload("res://assets/sprites/hats/cap.png")
const COWBOY = preload("res://assets/sprites/hats/cowboy.png")
const SOMBRARO = preload("res://assets/sprites/hats/sombraro.png")
const WITCH_HAT = preload("res://assets/sprites/hats/witch_hat.png")

# Grab the original stylebox from the scene before we ever override it
var _normal_style: StyleBoxFlat
var _selected_style: StyleBoxFlat

func _ready() -> void:
	# Duplicate the stylebox that's baked into the scene so we can restore it later
	_normal_style = panel.get_theme_stylebox("panel").duplicate()

	_selected_style = StyleBoxFlat.new()
	_selected_style.bg_color = Color(0.27, 0.27, 0.27, 1)
	_selected_style.border_width_left = 4
	_selected_style.border_width_right = 4
	_selected_style.border_width_top = 4
	_selected_style.border_width_bottom = 4
	_selected_style.border_color = Color(1, 0.7, 0.0, 1)
	_selected_style.border_blend = true
	_selected_style.corner_radius_top_left = 20
	_selected_style.corner_radius_top_right = 20
	_selected_style.corner_radius_bottom_right = 20
	_selected_style.corner_radius_bottom_left = 20

func _process(_delta: float) -> void:
	progress_bar.value = ((Time.get_unix_time_from_system() - order_time) / Enums.ORDER_TIMEOUT_SEC) * 100

func set_order_time(time: float):
	order_time = time

func set_order_number(i: int):
	item_number.text = str(i)

func set_selected(is_selected: bool) -> void:
	if is_selected:
		panel.add_theme_stylebox_override("panel", _selected_style)
		selected_indicator.visible = true
	else:
		if _normal_style:
			panel.add_theme_stylebox_override("panel", _normal_style)
		else:
			panel.remove_theme_stylebox_override("panel")
		selected_indicator.visible = false

func setType(t: Enums.OrderType):
	match t:
		Enums.OrderType.HAPPY:
			happy.visible = true
		Enums.OrderType.ANGRY:
			angry.visible = true
		Enums.OrderType.SURPRISED:
			surprised.visible = true

func set_hat(h: Enums.HatType):
	match h:
		Enums.HatType.WITCH:
			hat_image.visible = true
			hat_image.texture = WITCH_HAT
		Enums.HatType.CAP:
			hat_image.visible = true
			hat_image.texture = CAP
		Enums.HatType.COWBOY:
			hat_image.visible = true
			hat_image.texture = COWBOY
		Enums.HatType.SOMBRARO:
			hat_image.visible = true
			hat_image.texture = SOMBRARO
