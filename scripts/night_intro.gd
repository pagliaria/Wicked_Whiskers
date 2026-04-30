extends Control

signal intro_finished

@onready var stats_panel: Control = $StatsPanel
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

var _night_num: int = 1

func setup(night_num: int) -> void:
	_night_num = night_num
	night_label.text = "Night  %d" % night_num
	subtitle_label.text = SUBTITLES[night_num - 1]
	tip_label.text = TIPS[night_num - 1]

	# Night 1 has no previous night stats — go straight to intro
	if night_num == 1:
		stats_panel.visible = false
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
		intro_panel.visible = false
		continue_btn.grab_focus()

func _ready() -> void:
	anim.play("fade_in")

func _on_continue_pressed() -> void:
	stats_panel.visible = false
	intro_panel.visible = true
	begin_btn.grab_focus()

func _on_begin_pressed() -> void:
	anim.play("fade_out")
	await anim.animation_finished
	intro_finished.emit()
	queue_free()
