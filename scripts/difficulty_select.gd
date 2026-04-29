extends Control

signal difficulty_chosen

@onready var easy_button: Button = $Panel/VBox/EasyCenter/EasyButton

func _ready() -> void:
	easy_button.grab_focus()

func _on_easy_pressed() -> void:
	Enums.set_difficulty(Enums.Difficulty.EASY)
	difficulty_chosen.emit()
	queue_free()

func _on_normal_pressed() -> void:
	Enums.set_difficulty(Enums.Difficulty.NORMAL)
	difficulty_chosen.emit()
	queue_free()

func _on_hard_pressed() -> void:
	Enums.set_difficulty(Enums.Difficulty.HARD)
	difficulty_chosen.emit()
	queue_free()
