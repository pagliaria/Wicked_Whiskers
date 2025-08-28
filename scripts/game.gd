extends Node2D

@export var customer: PackedScene
@onready var night_timer: Timer = $night_timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var player: CharacterBody2D = $Player
@onready var spawn_timer: Timer = $spwan_point/spawn_timer
@onready var happy_cat: StaticBody2D = $happy_cat
@onready var angry_cat: StaticBody2D = $angry_cat
@onready var surprised_cat: StaticBody2D = $surprised_cat
@onready var win: Label = $win
@onready var night: Label = $night
@onready var next_night: Label = $next_night

var orderTime
var night_start_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OrderManager.set_order_display($orders/MarginContainer/orders_display)
	night_start_time = Time.get_unix_time_from_system()
	new_night(Enums.get_night())

func _on_spawn_timer_timeout() -> void:
	var customer_scene_instance = customer.instantiate()
	customer_scene_instance.global_position = $spwan_point.global_position
	add_child(customer_scene_instance, true)

func _process(_delta: float) -> void:
	progress_bar.value = ((Time.get_unix_time_from_system() - night_start_time) / Enums.get_night_time()) * 100
	
	if progress_bar.value == 100:
		Enums.set_passed(true)
		day_end()
		
func day_end():
	print("new day!")
	spawn_timer.stop()
	OrderManager.clear_all_orders()
	if Enums.get_night() == 3:
		win.visible = true
	else:
		next_night.visible = true
		
	get_tree().paused = true

func new_night(d:int):
	night.text = "Night " + str(Enums.get_night())
	
	match d:
		1:
			spawn_timer.start(10)
			Enums.ORDER_TIMEOUT_SEC = 30
		2:
			spawn_timer.start(8)
			Enums.ORDER_TIMEOUT_SEC = 25
			angry_cat.visible = true
			angry_cat.set_collision_layer_value(1, true)
			angry_cat.process_mode = Node.PROCESS_MODE_INHERIT
		3:
			spawn_timer.start(6)
			Enums.ORDER_TIMEOUT_SEC = 20
			angry_cat.visible = true
			angry_cat.set_collision_layer_value(1, true)
			angry_cat.process_mode = Node.PROCESS_MODE_INHERIT
			surprised_cat.visible = true
			surprised_cat.set_collision_layer_value(1, true)
			surprised_cat.process_mode = Node.PROCESS_MODE_INHERIT
