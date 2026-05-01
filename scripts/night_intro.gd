extends Control

signal intro_finished

@onready var stats_panel: Control = $StatsPanel
@onready var shop_panel: Control = $ShopPanel
@onready var intro_panel: Control = $IntroPanel
@onready var night_label: Label = $IntroPanel/VBox/NightLabel
@onready var subtitle_label: Label = $IntroPanel/VBox/SubtitleLabel
@onready var tip_label: Label = $IntroPanel/VBox/TipLabel
@onready var begin_btn: Button = $IntroPanel/VBox/BeginCenter/BeginButton
@onready var anim: AnimationPlayer = $AnimationPlayer

# Stats panel refs
@onready var stats_night_label: Label = $StatsPanel/VBox/NightLabel
@onready var completed_label: Label = $StatsPanel/VBox/StatsGrid/CompletedVal
@onready var failed_label: Label = $StatsPanel/VBox/StatsGrid/FailedVal
@onready var coins_label: Label = $StatsPanel/VBox/StatsGrid/CoinsVal
@onready var score_label: Label = $StatsPanel/VBox/StatsGrid/ScoreVal
@onready var continue_btn: Button = $StatsPanel/VBox/ContinueCenter/ContinueButton

# Shop panel refs
@onready var shop_coins_label: Label = $ShopPanel/VBox/CoinsRow/ShopCoinsVal
@onready var boots_btn: Button = $ShopPanel/VBox/Items/BootsRow/BootsButton
@onready var time_btn: Button = $ShopPanel/VBox/Items/TimeRow/TimeButton
@onready var growth_btn: Button = $ShopPanel/VBox/Items/GrowthRow/GrowthButton
@onready var boots_status: Label = $ShopPanel/VBox/Items/BootsRow/BootsStatus
@onready var time_status: Label = $ShopPanel/VBox/Items/TimeRow/TimeStatus
@onready var growth_status: Label = $ShopPanel/VBox/Items/GrowthRow/GrowthStatus

const SUBTITLES = [
	"The pumpkins won't carve themselves...",
	"Angry customers await. Don't be slow.",
	"The final night. Give it everything."
]

const TIPS = [
	"Tip: Match the cat colour to the pumpkin expression the customer wants.",
	"Tip: Spend coins at the dog house to summon a Hell Hound for protection.",
	"Tip: Long throws score more points — but only if they land!"
]

const COST_BOOTS = 20
const COST_TIME = 30
const COST_GROWTH = 25

var _night_num: int = 1

func setup(night_num: int) -> void:
	_night_num = night_num
	night_label.text = "Night  %d" % night_num
	subtitle_label.text = SUBTITLES[night_num - 1]
	tip_label.text = TIPS[night_num - 1]

	# Night 1 has no previous night stats — go straight to intro
	if night_num == 1:
		stats_panel.visible = false
		shop_panel.visible = false
		intro_panel.visible = true
		begin_btn.grab_focus()
	else:
		var prev = night_num - 1
		stats_night_label.text = "Night %d Complete!" % prev
		completed_label.text = str(Enums.orders_completed)
		failed_label.text = str(Enums.orders_failed)
		coins_label.text = str(Enums.coins_earned_this_night)
		score_label.text = str(Enums.score_earned_this_night)
		stats_panel.visible = true
		shop_panel.visible = false
		intro_panel.visible = false
		continue_btn.grab_focus()

func _refresh_shop() -> void:
	shop_coins_label.text = str(Enums.coins)

	# Swift Boots
	if Enums.upgrade_swift_boots:
		boots_btn.disabled = true
		boots_btn.text = "OWNED"
		boots_status.text = "✓ Equipped"
		boots_status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	else:
		boots_btn.disabled = Enums.coins < COST_BOOTS
		boots_btn.text = "Buy  (%d coins)" % COST_BOOTS
		boots_status.text = "+20 move speed"
		boots_status.remove_theme_color_override("font_color")

	# Extra Time
	if Enums.upgrade_extra_time:
		time_btn.disabled = true
		time_btn.text = "OWNED"
		time_status.text = "✓ Equipped"
		time_status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	else:
		time_btn.disabled = Enums.coins < COST_TIME
		time_btn.text = "Buy  (%d coins)" % COST_TIME
		time_status.text = "+5 sec order timeout"
		time_status.remove_theme_color_override("font_color")

	# Fast Growth
	if Enums.upgrade_fast_growth:
		growth_btn.disabled = true
		growth_btn.text = "OWNED"
		growth_status.text = "✓ Equipped"
		growth_status.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4, 1))
	else:
		growth_btn.disabled = Enums.coins < COST_GROWTH
		growth_btn.text = "Buy  (%d coins)" % COST_GROWTH
		growth_status.text = "Faster pumpkin patches"
		growth_status.remove_theme_color_override("font_color")

func _ready() -> void:
	anim.play("fade_in")

func _on_continue_pressed() -> void:
	stats_panel.visible = false
	shop_panel.visible = true
	intro_panel.visible = false
	_refresh_shop()
	boots_btn.grab_focus()

func _on_shop_continue_pressed() -> void:
	shop_panel.visible = false
	intro_panel.visible = true
	begin_btn.grab_focus()

func _on_boots_pressed() -> void:
	if Enums.upgrade_swift_boots || Enums.coins < COST_BOOTS:
		return
	Enums.coins -= COST_BOOTS
	Enums.upgrade_swift_boots = true
	Enums.player_speed = 150.0
	_refresh_shop()

func _on_time_pressed() -> void:
	if Enums.upgrade_extra_time || Enums.coins < COST_TIME:
		return
	Enums.coins -= COST_TIME
	Enums.upgrade_extra_time = true
	Enums.ORDER_TIMEOUT_SEC += 5
	_refresh_shop()

func _on_growth_pressed() -> void:
	if Enums.upgrade_fast_growth || Enums.coins < COST_GROWTH:
		return
	Enums.coins -= COST_GROWTH
	Enums.upgrade_fast_growth = true
	Enums.pumpkin_grow_interval = 1.5
	_refresh_shop()

func _on_begin_pressed() -> void:
	anim.play("fade_out")
	await anim.animation_finished
	intro_finished.emit()
	queue_free()
