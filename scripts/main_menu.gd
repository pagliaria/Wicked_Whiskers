extends Control

@export var how_to_play_scene: PackedScene
@export var difficulty_select_scene: PackedScene
@export var multiplayer_menu_scene: PackedScene

@onready var char_select_image: Sprite2D = $CenterContainer/Panel/CharPanel/char_select_image
@onready var single_player_btn: Button = $CenterContainer/Panel/single_player

const KNIGHT = preload("res://assets/sprites/characters/knight.png")
const WITCH_001_SWEN = preload("res://assets/sprites/characters/witch-001-SWEN.png")
const WITCH_002_SWEN = preload("res://assets/sprites/characters/witch-002-SWEN.png")
const SKELETON = preload("res://assets/sprites/characters/elder_skeleton-SWEN.png")

var char_select = Enums.CharSelection.KNIGHT

func _ready() -> void:
	single_player_btn.grab_focus()
	# Wire Change button into the focus chain so controller can reach it
	var change = $CenterContainer/Panel/CharPanel/change_char
	var how_to_play = $CenterContainer/Panel/how_to_play
	how_to_play.focus_neighbor_bottom = how_to_play.get_path_to(change)
	how_to_play.focus_next = how_to_play.get_path_to(change)
	change.focus_neighbor_top = change.get_path_to(how_to_play)
	change.focus_neighbor_bottom = change.get_path_to(single_player_btn)
	change.focus_previous = change.get_path_to(how_to_play)
	change.focus_next = change.get_path_to(single_player_btn)
	single_player_btn.focus_neighbor_top = single_player_btn.get_path_to(change)
	single_player_btn.focus_previous = single_player_btn.get_path_to(change)

func _on_single_player_pressed() -> void:
	var popup = difficulty_select_scene.instantiate()
	get_tree().root.add_child(popup)
	popup.difficulty_chosen.connect(func():
		MultiplayerManager.Players[1] = {
			"name": "",
			"id": 1,
			"char": char_select
		}
		get_tree().change_scene_to_file("res://scenes/game.tscn")
	)

func _on_multiplayer_pressed() -> void:
	var popup = multiplayer_menu_scene.instantiate()
	get_tree().root.add_child(popup)

func _on_how_to_play_pressed() -> void:
	var popup = how_to_play_scene.instantiate()
	get_tree().root.add_child(popup)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_change_char_pressed() -> void:
	char_select += 1
	if char_select > Enums.CharSelection.size() - 1:
		char_select = 0
	set_character(char_select_image, char_select)

func set_character(sprite: Sprite2D, c: Enums.CharSelection):
	match c:
		Enums.CharSelection.KNIGHT:
			sprite.texture = KNIGHT
			sprite.region_rect = Rect2(1, 3, 30, 32)
			sprite.scale = Vector2(3.3, 3.3)
		Enums.CharSelection.WITCH:
			sprite.texture = WITCH_001_SWEN
			sprite.region_rect = Rect2(97, 76, 47, 55)
			sprite.scale = Vector2(1.5, 1.5)
		Enums.CharSelection.BLUE_WITCH:
			sprite.texture = WITCH_002_SWEN
			sprite.region_rect = Rect2(97, 76, 47, 55)
			sprite.scale = Vector2(1.5, 1.5)
		Enums.CharSelection.SKELETON:
			sprite.texture = SKELETON
			sprite.region_rect = Rect2(48, 2, 46, 66)
			sprite.scale = Vector2(1.5, 1.5)
