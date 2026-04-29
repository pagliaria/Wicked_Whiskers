extends Control

signal intro_finished

@onready var night_label: Label = $VBox/NightLabel
@onready var subtitle_label: Label = $VBox/SubtitleLabel
@onready var tip_label: Label = $VBox/TipLabel
@onready var begin_btn: Button = $VBox/BeginButton
@onready var anim: AnimationPlayer = $AnimationPlayer

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

func setup(night_num: int) -> void:
	night_label.text = "Night  %d" % night_num
	subtitle_label.text = SUBTITLES[night_num - 1]
	tip_label.text = TIPS[night_num - 1]

func _ready() -> void:
	begin_btn.grab_focus()
	anim.play("fade_in")

func _on_begin_pressed() -> void:
	anim.play("fade_out")
	await anim.animation_finished
	intro_finished.emit()
	queue_free()
