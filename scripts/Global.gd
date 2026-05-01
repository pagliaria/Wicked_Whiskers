extends Node

var night = 1
var night_time_sec = 120
var ORDER_TIMEOUT_SEC = 30
var coins = 0
var score = 0
var coin_counter_pos
var night_passed = false

# Per-night stats — reset at the start of each night
var orders_completed: int = 0
var orders_failed: int = 0
var coins_earned_this_night: int = 0
var score_earned_this_night: int = 0

# Cumulative totals across all nights
var total_orders_completed: int = 0
var total_orders_failed: int = 0
var total_attacks_received: int = 0
var total_times_caught: int = 0

func reset_night_stats() -> void:
	total_orders_completed += orders_completed
	total_orders_failed += orders_failed
	orders_completed = 0
	orders_failed = 0
	coins_earned_this_night = 0
	score_earned_this_night = 0

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

enum Difficulty {
	EASY,
	NORMAL,
	HARD
}

# Base ORDER_TIMEOUT_SEC per night (normal difficulty, 1 player)
# Indexed by night (0 = night 1, 1 = night 2, 2 = night 3)
const BASE_ORDER_TIMEOUT = [25, 23, 21]

# Base spawn interval in seconds per night (normal difficulty, 1 player)
const BASE_SPAWN_INTERVAL = [10, 9, 8]

# Difficulty modifiers applied to timeouts and spawn intervals.
# Timeout: higher = more generous. Spawn: higher = less frequent (easier).
const DIFFICULTY_TIMEOUT_MOD = {
	Difficulty.EASY:   5,
	Difficulty.NORMAL: 0,
	Difficulty.HARD:  -5
}

const DIFFICULTY_SPAWN_MOD = {
	Difficulty.EASY:   3,
	Difficulty.NORMAL: 0,
	Difficulty.HARD:  -2
}

var difficulty: Difficulty = Difficulty.NORMAL

# Upgrades purchased in the between-night shop
var upgrade_swift_boots: bool = false
var upgrade_extra_time: bool = false
var upgrade_fast_growth: bool = false

# Player speed — modified by swift boots upgrade
var player_speed: float = 130.0

# Pumpkin grow interval in seconds — modified by fast growth upgrade
var pumpkin_grow_interval: float = 2.5

func get_night() -> int:
	return night

func set_night(n: int):
	night = n

func get_night_time() -> int:
	return night_time_sec

func set_passed(p: bool):
	night_passed = p

func get_passed() -> bool:
	return night_passed

func set_difficulty(d: Difficulty):
	difficulty = d

func get_difficulty() -> Difficulty:
	return difficulty

func get_order_timeout(night_num: int, player_count: int) -> int:
	var base = BASE_ORDER_TIMEOUT[night_num - 1]
	var mod = DIFFICULTY_TIMEOUT_MOD[difficulty]
	return base + mod - player_count

func get_spawn_interval(night_num: int, player_count: int) -> float:
	var base = BASE_SPAWN_INTERVAL[night_num - 1]
	var mod = DIFFICULTY_SPAWN_MOD[difficulty]
	return float(base + mod - player_count)
