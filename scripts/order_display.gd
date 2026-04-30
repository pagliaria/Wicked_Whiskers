extends Control

var order_time
var _order_number: int = -1
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
var _warning_style: StyleBoxFlat
var _warning_selected_style: StyleBoxFlat
var _pulse_fill_style: StyleBoxFlat

const WARNING_THRESHOLD = 75.0  # progress % at which pulsing begins
const PULSE_SPEED = 4.0         # oscillations per second
const COLOR_PANEL_WARN = Color(0.45, 0.08, 0.08, 1.0)
const COLOR_FILL_WARN  = Color(0.95, 0.15, 0.15, 1.0)

var _pulsing := false
var _pulse_time := 0.0
var pause_time = 0.0

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

	# Warning panel style — same shape as normal, red tinted bg
	_warning_style = _normal_style.duplicate()
	_warning_style.bg_color = COLOR_PANEL_WARN

	# Warning + selected: red bg with gold border
	_warning_selected_style = _selected_style.duplicate()
	_warning_selected_style.bg_color = COLOR_PANEL_WARN

	# Warning fill style — duplicated from the progress bar's current fill
	_pulse_fill_style = progress_bar.get_theme_stylebox("fill").duplicate()

func _process(delta: float) -> void:
	var progress: float = ((Time.get_unix_time_from_system() - order_time - pause_time) / Enums.ORDER_TIMEOUT_SEC) * 100
	progress_bar.value = progress

	if progress >= WARNING_THRESHOLD:
		_pulse_time += delta
		if not _pulsing:
			_pulsing = true
			panel.add_theme_stylebox_override("panel", _warning_style)
			progress_bar.add_theme_stylebox_override("fill", _pulse_fill_style)
			_set_customer_warning(true)
		# Sine wave: 0.0 → 1.0 → 0.0, PULSE_SPEED times per second
		var t: float = (sin(_pulse_time * PULSE_SPEED * TAU) + 1.0) * 0.5
		var warn_bg = _normal_style.bg_color.lerp(COLOR_PANEL_WARN, t)
		_warning_style.bg_color = warn_bg
		_warning_selected_style.bg_color = warn_bg
		_pulse_fill_style.bg_color = Color(0.977949, 0.230255, 0.769886, 1).lerp(COLOR_FILL_WARN, t)
	elif _pulsing:
		# Progress went back below threshold (shouldn't normally happen, but be safe)
		_stop_pulse()

func add_pause_time(time: float):
	pause_time = time

func set_order_time(time: float):
	order_time = time

func set_order_number(i: int):
	_order_number = i
	item_number.text = str(i)

func set_selected(is_selected: bool) -> void:
	selected_indicator.visible = is_selected
	if is_selected:
		var style = _warning_selected_style if _pulsing else _selected_style
		panel.add_theme_stylebox_override("panel", style)
	else:
		var style = _warning_style if _pulsing else _normal_style
		panel.add_theme_stylebox_override("panel", style)

func _stop_pulse() -> void:
	_pulsing = false
	_pulse_time = 0.0
	panel.add_theme_stylebox_override("panel", _normal_style)
	progress_bar.remove_theme_stylebox_override("fill")
	_set_customer_warning(false)

func _set_customer_warning(active: bool) -> void:
	if _order_number == -1:
		return
	var order = OrderManager.get_order(_order_number)
	if order == null:
		return
	var customer = order.get_customer()
	if customer != null && customer.has_method("set_urgent"):
		customer.set_urgent(active)

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
