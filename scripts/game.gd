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
@onready var customer_spwan_point: Node2D = $customer_spwan_point
@onready var pumpkin_spawn_locations: Node = $pumpkin_spawn_locations
@onready var cat_spawn_locations: Node = $cat_spawn_locations

var cat_spawns = []
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
		current_player.set_char_select(MultiplayerManager.Players[p].char)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
		
	new_night(Enums.get_night())

func _on_spawn_timer_timeout() -> void:
	if !is_multiplayer_authority():
		return
	
	var int_rand = randi_range(0, MultiplayerManager.Players.size()-1) 	
	var found_nodes: Array[CharacterBody2D] = []

	for child in get_children():
		# Check if the child is a Label or a node with a 'text' property
		if child is CharacterBody2D:
			if child.name.contains("Player"):
				found_nodes.append(child)
		
	var customer_scene_instance = customer.instantiate()
	#customer_scene_instance.global_position = spwan_point.global_position
	#add_child(customer_scene_instance, true)
	customer_spwan_point.add_child(customer_scene_instance, true)
	customer_scene_instance.set_player(found_nodes[int_rand].get_path())
	customer_scene_instance.global_position = customer_spwan_point.global_position

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
		if is_multiplayer_authority():
			next_night.visible = true
		else:
			next_night.text = "Waiting for host to continue..."
			next_night.visible = true
		
	get_tree().paused = true

func add_cats(n: int, type:Enums.OrderType):
	if !is_multiplayer_authority():
		return
		
	var spawns = []
	
	for i in n:
		var rand = randi_range(0, 10)
		while cat_spawns.has(rand):
			rand = randi_range(0, 10)
		spawns.append(rand)
		cat_spawns.append(rand)
	print("cat locations: ", spawns)
	
	for location in spawns:
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
		var patch_scene:Node2D = patch.instantiate()
		pumpkin_spawn_locations.add_child(patch_scene, true)
		var position_node =  pumpkin_spawn_locations.get_node(str(location))
		patch_scene.global_position = position_node.global_position

func new_night(d:int):
	night.text = "Night " + str(Enums.get_night())
	var player_count = MultiplayerManager.Players.size()
	match d:
		1:			
			Enums.ORDER_TIMEOUT_SEC = 25 - player_count
			spawn_timer.start(10 - player_count)
			
			#Spawn pumpkin patches
			add_pumpkin_patchs(player_count)
			#Spawn cats
			cat_spawns.clear()
			add_cats(ceil(float(player_count)/2), Enums.OrderType.HAPPY)

		2:
			Enums.ORDER_TIMEOUT_SEC = 20 - player_count
			spawn_timer.start(8 - player_count)
			
			#Spawn pumpkin patches
			add_pumpkin_patchs(player_count+1)
			#Spawn cats
			cat_spawns.clear()
			add_cats(ceil(float(player_count)/2), Enums.OrderType.HAPPY)
			add_cats(ceil(float(player_count)/2), Enums.OrderType.ANGRY)
			
		3:
			Enums.ORDER_TIMEOUT_SEC = 15 - player_count
			spawn_timer.start(6 - player_count)
			
			#Spawn pumpkin patches
			add_pumpkin_patchs(player_count+1)
			#Spawn cats
			cat_spawns.clear()
			add_cats(ceil(float(player_count)/2), Enums.OrderType.HAPPY)
			add_cats(ceil(float(player_count)/2), Enums.OrderType.ANGRY)
			add_cats(ceil(float(player_count)/2), Enums.OrderType.SURPRISED)

func clean_up():
	var children = pumpkin_spawn_locations.get_children()
	for child in children:
		if child.name.contains("patch"):
			for pump in child.get_node("spawn_nodes").get_children():
				pump.queue_free()
		if is_instance_valid(child):
			child.queue_free()
			
	children = cat_spawn_locations.get_children()
	for child in children:
		if is_instance_valid(child):
			child.queue_free()
			
	children = customer_spwan_point.get_children()
	for child in children:
		if is_instance_valid(child):
			child.queue_free()
