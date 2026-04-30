extends Control

func setup() -> void:
	$Background/Panel/VBox/StatsCenter/StatsGrid/TotalScoreVal.text = str(Enums.score)
	$Background/Panel/VBox/StatsCenter/StatsGrid/TotalCoinsVal.text = str(Enums.coins)
	$Background/Panel/VBox/StatsCenter/StatsGrid/CompletedVal.text = str(Enums.total_orders_completed)
	$Background/Panel/VBox/StatsCenter/StatsGrid/FailedVal.text = str(Enums.total_orders_failed)

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
	get_tree().paused = false

func _on_play_again_pressed() -> void:
	_reset_globals()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_main_menu_pressed() -> void:
	_reset_globals()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
