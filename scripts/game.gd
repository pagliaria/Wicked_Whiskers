extends Node2D

@export var player_scene: PackedScene
@export var customer: PackedScene
@export var cat: PackedScene
@export var patch: PackedScene
@export var night_intro_scene: PackedScene
@export var win_screen_scene: PackedScene

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
@onready var coins_amount: Label = $coins_amount
@onready var score_amount: Label = $score_amount
@onready var coin_end: Node2D = $coin_end
@onready var hell_dog: CharacterBody2D = $hell_dog
@onready var dog_house: StaticBody2D = $dog_house
@onready var night_modulate: CanvasModulate = $night_modulate

var players = []
var cat_spawns = []
var orderTime
var night_start_time
var transitioning_to_next_night = false
var _paused_at: float = -1.0
var _total_paused_duration: float = 0.0

func _ready() -> void:
	dog_house.set_dog(hell_dog)
	hell_dog.set_customer_spawn_point(customer_spwan_point)
	OrderManager.set_order_display($orders/MarginContainer/orders_display)
	Enums.coin_counter_pos = coin_end.global_position
	
	var index = 0
	for p in MultiplayerManager.Players:
		var current_player = player_scene.instantiate()
		add_child(current_player, true)
		current_player.set_player_id(MultiplayerManager.Players[p].id)
		current_player.set_player_name(MultiplayerManager.Players[p].name)
		current_player.set_char_select(MultiplayerManager.Players[p].char)
		
		players.append(current_player)
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		
	show_night_intro()
	
func set_players_visibility(vis: bool):
	for player in players:
		player.visible = vis
		
func _on_spawn_timer_timeout() -> void:
	if !is_multiplayer_authority():
		return
	
	var int_rand = randi_range(0, MultiplayerManager.Players.size()-1)
	var found_nodes: Array[CharacterBody2D] = []

	for child in get_children():
		if child is CharacterBody2D:
			if child.name.contains("Player"):
				found_nodes.append(child)
		
	var customer_scene_instance = customer.instantiate()
	customer_spwan_point.add_child(customer_scene_instance, true)
	customer_scene_instance.set_player(found_nodes[int_rand].get_path())
	customer_scene_instance.global_position = customer_spwan_point.global_position

func _process(_delta: float) -> void:
	var elapsed = (Time.get_unix_time_from_system() - night_start_time) - _total_paused_duration
	progress_bar.value = (elapsed / Enums.get_night_time()) * 100
	coins_amount.text = str(Enums.coins)
	score_amount.text = str(Enums.score)
	
	if progress_bar.value >= 100 && !transitioning_to_next_night:
		Enums.set_passed(true)
		day_end()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		_paused_at = Time.get_unix_time_from_system()
	elif what == NOTIFICATION_UNPAUSED:
		if _paused_at > 0.0:
			_total_paused_duration += Time.get_unix_time_from_system() - _paused_at
			OrderManager.add_paused_time(_total_paused_duration)
			_paused_at = -1.0

func day_end():
	transitioning_to_next_night = true
	print("new day!")
	spawn_timer.stop()
	OrderManager.clear_all_orders()
	if Enums.get_night() == 3:
		Enums.total_orders_completed += Enums.orders_completed
		Enums.total_orders_failed += Enums.orders_failed
		get_tree().paused = true
		if win_screen_scene != null:
			var win_layer := CanvasLayer.new()
			win_layer.layer = 20
			win_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			add_child(win_layer)
			var win_screen = win_screen_scene.instantiate()
			win_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			win_layer.add_child(win_screen)
		else:
			win.visible = true
	else:
		if is_multiplayer_authority():
			clean_up()
			advance_to_next_night.rpc()
		else:
			next_night.text = "Waiting for next night..."
			next_night.visible = true

func add_cats(n: int, type: Enums.OrderType):
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
		var cat_scene: Node2D = cat.instantiate()
		cat_spawn_locations.add_child(cat_scene, true)
		cat_scene.set_type.rpc(type)
		var position_node = cat_spawn_locations.get_node(str(location))
		cat_scene.global_position = position_node.global_position

func add_pumpkin_patchs(n: int):
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
		var patch_scene: Node2D = patch.instantiate()
		pumpkin_spawn_locations.add_child(patch_scene, true)
		var position_node = pumpkin_spawn_locations.get_node(str(location))
		patch_scene.global_position = position_node.global_position

func _apply_night_tint(night_num: int) -> void:
	match night_num:
		1:
			night_modulate.color = Color(1.0, 0.96, 0.88, 1.0)  # soft amber - calm harvest night
		2:
			night_modulate.color = Color(0.88, 0.92, 1.0, 1.0)  # subtle blue - eerie midnight
		3:
			night_modulate.color = Color(1.0, 0.80, 0.85, 1.0)  # gentle red - hellish finale

func new_night(d: int):
	_apply_night_tint(d)
	night_start_time = Time.get_unix_time_from_system()
	_total_paused_duration = 0.0
	_paused_at = -1.0
	Enums.reset_night_stats()
	night.text = "Night " + str(Enums.get_night())
	var player_count = MultiplayerManager.Players.size()

	Enums.ORDER_TIMEOUT_SEC = Enums.get_order_timeout(d, player_count)
	spawn_timer.start(Enums.get_spawn_interval(d, player_count))

	match d:
		1:
			add_pumpkin_patchs(player_count)
			cat_spawns.clear()
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.HAPPY)
		2:
			add_pumpkin_patchs(player_count + 1)
			cat_spawns.clear()
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.HAPPY)
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.ANGRY)
		3:
			add_pumpkin_patchs(player_count + 1)
			cat_spawns.clear()
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.HAPPY)
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.ANGRY)
			add_cats(ceil(float(player_count) / 2), Enums.OrderType.SURPRISED)

func show_night_intro() -> void:
	if night_intro_scene == null:
		new_night(Enums.get_night())
		return

	get_tree().paused = true

	var intro_layer := CanvasLayer.new()
	intro_layer.layer = 20
	intro_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	add_child(intro_layer)

	var intro = night_intro_scene.instantiate()
	intro.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	intro_layer.add_child(intro)

	if intro.has_method("setup"):
		intro.setup(Enums.get_night())

	intro.intro_finished.connect(_on_night_intro_finished.bind(intro_layer), CONNECT_ONE_SHOT)

func _on_night_intro_finished(intro_layer: CanvasLayer) -> void:
	if is_instance_valid(intro_layer):
		intro_layer.queue_free()

	get_tree().paused = false
	new_night(Enums.get_night())

@rpc("any_peer", "call_local")
func advance_to_next_night() -> void:
	get_tree().paused = false
	Enums.set_night(Enums.get_night() + 1)
	Enums.set_passed(false)
	OrderManager.clear_all_orders()
	get_tree().reload_current_scene()

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
