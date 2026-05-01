extends Control

@onready var grade_label: Label = $Background/Panel/VBox/GradeLabel

func _compute_grade() -> Dictionary:
	var total = Enums.total_orders_completed + Enums.total_orders_failed
	var completion_ratio = float(Enums.total_orders_completed) / float(total) if total > 0 else 0.0

	# Score thresholds tuned against BASE_ORDER_TIMEOUT and 3 nights of play
	if completion_ratio >= 0.95 && Enums.score >= 1500:
		return { "grade": "S", "color": Color(1.0, 0.85, 0.2, 1.0) }   # gold
	elif completion_ratio >= 0.85 && Enums.score >= 1000:
		return { "grade": "A", "color": Color(0.4, 0.9, 0.4, 1.0) }    # green
	elif completion_ratio >= 0.70 && Enums.score >= 500:
		return { "grade": "B", "color": Color(0.4, 0.75, 1.0, 1.0) }   # blue
	elif completion_ratio >= 0.50:
		return { "grade": "C", "color": Color(0.92, 0.92, 0.92, 1.0) } # white
	else:
		return { "grade": "F", "color": Color(0.9, 0.35, 0.35, 1.0) }  # red

func setup() -> void:
	$Background/Panel/VBox/StatsCenter/StatsGrid/TotalScoreVal.text = str(Enums.score)
	$Background/Panel/VBox/StatsCenter/StatsGrid/TotalCoinsVal.text = str(Enums.coins)
	$Background/Panel/VBox/StatsCenter/StatsGrid/CompletedVal.text = str(Enums.total_orders_completed)
	$Background/Panel/VBox/StatsCenter/StatsGrid/FailedVal.text = str(Enums.total_orders_failed)

	var result = _compute_grade()
	grade_label.text = result["grade"]
	grade_label.add_theme_color_override("font_color", result["color"])

func _ready() -> void:
	setup()
	$Background/Panel/VBox/ButtonRow/PlayAgainButton.grab_focus()

func _reset_globals() -> void:
	Enums.night = 1
	Enums.coins = 0
	Enums.score = 0
	Enums.orders_completed = 0
	Enums.orders_failed = 0
	Enums.total_orders_completed = 0
	Enums.total_orders_failed = 0
	Enums.set_passed(false)
	Enums.upgrade_swift_boots = false
	Enums.upgrade_extra_time = false
	Enums.upgrade_fast_growth = false
	Enums.player_speed = 130.0
	Enums.pumpkin_grow_interval = 2.5
	get_tree().paused = false

func _on_play_again_pressed() -> void:
	_reset_globals()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_main_menu_pressed() -> void:
	_reset_globals()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
