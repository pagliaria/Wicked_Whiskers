extends Node

var night = 1
var night_time_sec = 180
#var night_time_sec = 10
var ORDER_TIMEOUT_SEC = 30
var coins = 0
var coin_counter_pos

var night_passed = false

enum HatType {
	NONE,
	WITCH,
	CAP,
	COWBOY,
	SOMBRARO
}

enum OrderType {
	INVALID,
	HAPPY,
	ANGRY,
	SURPRISED
}

enum CharSelection {
	KNIGHT,
	WITCH,
	BLUE_WITCH,
	SKELETON
}

func get_night() -> int:
	return night
	
func set_night(n:int):
	night = n

func get_night_time() ->int:
	return night_time_sec

func set_passed(p:bool):
	night_passed = p

func get_passed() ->bool:
	return night_passed
