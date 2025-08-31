extends Node2D

@export var player_scene: PackedScene
@export var customer: PackedScene
@export var cat: PackedScene
@export var patch: PackedScene

@onready var night_timer: Timer = $night_timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var spawn_timer: Timer = $customer_spwan_point/spawn_timer
@onready var happy_cat: StaticBody2D = $happy_cat
@onready var angry_cat: StaticBody2D = $angry_cat
@onready var surprised_cat: StaticBody2D = $surprised_cat
@onready var win: Label = $win
@onready var night: Label = $night
@onready var next_night: Label = $next_night
@onready var spwan_point: Node2D = $customer_spwan_point
@onready var pumpkin_spawn_locations: Node = $pumpkin_spawn_locations
@onready var cat_spawn_locations: Node = $cat_spawn_locations

var orderTime
var night_start_time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OrderManager.set_order_display($orders/MarginContainer/orders_display)
	night_start_time = Time.get_unix_time_from_system()
	
	#add players
	var index = 0
	for p in MultiplayerManager.Players:
		var current_player = player_scene.instantiate()
		add_child(current_player, true)
		current_player.set_player_id(MultiplayerManager.Players[p].id)
		current_player.set_player_name(MultiplayerManager.Players[p].name)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
		
	new_night(Enums.get_night())

func _on_spawn_timer_timeout() -> void:
	if !is_multiplayer_authority():
		return
	
	var customer_scene_instance = customer.instantiate()
	#customer_scene_instance.global_position = spwan_point.global_position
	#add_child(customer_scene_instance, true)
	spwan_point.add_child(customer_scene_instance, true)
	customer_scene_instance.global_position = spwan_point.global_position

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

func add_cats(n: int, type:Enums.OrderType):
	if !is_multiplayer_authority():
		return
		
	var spawns = []
	for i in n:
		var rand = randi_range(0, 10)
		while spawns.has(rand):
			rand = randi_range(0, 10)
		spawns.append(rand)
	print("cat locations: ", spawns)
	
	for location in spawns:
		var node:Node = cat_spawn_locations.get_node(str(location))
		var cat_scene:Node2D = cat.instantiate()
		cat_spawn_locations.add_child(cat_scene, true)
		cat_scene.set_type.rpc(type)
		var position_node =  cat_spawn_locations.get_node(str(location))
		cat_scene.global_position = position_node.global_position
		
# Generate patches. cant do more than there are spawn locations in "pumpkin_spawn_locations"
func add_pumpkin_patchs(n:int):
	if !is_multiplayer_authority():
		return
		
	var spawns = []
	for i in n:
		var rand = randi_range(0, 10)
		while spawns.has(rand):
			rand = randi_range(0, 10)
		spawns.append(rand)
	print("patch locations: ", spawns)
	
	for location in spawns:
		var node:Node = pumpkin_spawn_locations.get_node(str(location))
		#var spawner = MultiplayerSpawner.new()
		#add_child(spawner)
		#spawner.spawn_path = NodePath(node.get_path()) 
		var patch_scene:Node2D = patch.instantiate()
		pumpkin_spawn_locations.add_child(patch_scene, true)
		var position_node =  pumpkin_spawn_locations.get_node(str(location))
		patch_scene.global_position = position_node.global_position

func new_night(d:int):
	night.text = "Night " + str(Enums.get_night())
	
	match d:
		1:
			spawn_timer.start(10)
			Enums.ORDER_TIMEOUT_SEC = 30
			
			#Spawn pumpkin patches
			add_pumpkin_patchs(2)
			#Spawn cats
			add_cats(2, Enums.OrderType.HAPPY)
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
