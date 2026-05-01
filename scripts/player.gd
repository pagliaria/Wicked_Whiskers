extends CharacterBody2D

const SPEED = 130.0
const THROW_SPEED = 300
const SPIN_SPEED = 2000
const GAME_OVER_MENU = preload("res://scenes/game_over_menu.tscn")

@onready var throw: AudioStreamPlayer2D = $throw
@onready var squish: AudioStreamPlayer2D = $squish
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $death_timer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var player_name: Label = $Panel/name

var current_item_in_range: RigidBody2D = null
var current_held_item: RigidBody2D = null
var current_cat_in_range: StaticBody2D = null
var current_table_in_range: StaticBody2D = null
var current_dog_house_in_range: StaticBody2D = null
var facingRight = true
var target_node = null
var throw_order = false
var dead = false
var player_id
var char_select: Enums.CharSelection = Enums.CharSelection.KNIGHT
var idle_string = "idle"
var moving_string = "moving"

# Controller order cycling
var selected_order: int = 1
var _throw_start_pos: Vector2 = Vector2.ZERO
var _throw_order_time: float = 0.0
var _throw_order_num: int = -1
var default_sprite_position := Vector2.ZERO
var default_sprite_scale := Vector2.ONE

func _ready() -> void:
	default_sprite_position = sprite.position
	default_sprite_scale = sprite.scale
	sprite.visible = false
	sprite.stop()

func _unhandled_input(event):
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if dead:
		return

	# Keyboard: direct order selection via number keys 1-5
	for i in range(1, 6):
		if event.is_action_pressed("order" + str(i)):
			_try_submit_order(i)

	# Controller: cycle through orders with LB/RB
	if event.is_action_pressed("order_next"):
		_cycle_order(1)
	if event.is_action_pressed("order_prev"):
		_cycle_order(-1)

	# Controller: B button submits the selected order
	if event.is_action_pressed("order_submit"):
		_try_submit_order(selected_order)

	if event.is_action_pressed("interact"):
		_handle_interact()

func _cycle_order(direction: int) -> void:
	# Find all active order numbers and cycle through them
	var active_orders = OrderManager.orders.keys()
	active_orders.sort()
	if active_orders.is_empty():
		return
	var current_idx = active_orders.find(selected_order)
	current_idx = (current_idx + direction + active_orders.size()) % active_orders.size()
	selected_order = active_orders[current_idx]
	OrderManager.highlight_order(selected_order)

func _try_submit_order(num: int) -> void:
	var order = OrderManager.get_order(num)
	if order != null && current_held_item != null:
		selected_order = num
		target_node = order.get_customer()
		# Capture throw info for scoring
		_throw_start_pos = global_position
		_throw_order_time = Time.get_unix_time_from_system() - order.get_order_time()
		_throw_order_num = num
		turn_in_order.rpc(current_held_item.get_path(), num)
		print("have it!")
		play_sound.rpc(throw.get_path())
		current_held_item.set_player.rpc(self.get_path())
		current_held_item.lock_rotation = false
		throw_order = true

func _handle_interact() -> void:
	if current_cat_in_range != null && current_held_item != null && !current_held_item.name.contains("jack") && !current_cat_in_range.is_busy():
		# Give pumpkin to cat
		print("gave pumpkin to cat!")
		play_sound.rpc(squish.get_path())
		current_cat_in_range.carve.rpc()
		delete_pumpkin.rpc(current_held_item.get_path())
		current_cat_in_range = null
	elif current_dog_house_in_range != null && current_dog_house_in_range.get_cost() <= Enums.coins && !current_dog_house_in_range.get_dog().is_active():
		Enums.coins -= current_dog_house_in_range.get_cost()
		current_dog_house_in_range.activate_dog()
	elif current_held_item != null && current_table_in_range != null && current_table_in_range.name.contains("witch"):
		current_held_item.add_hat.rpc(Enums.HatType.WITCH)
	elif current_held_item != null && current_table_in_range != null && current_table_in_range.name.contains("cap"):
		current_held_item.add_hat.rpc(Enums.HatType.CAP)
	elif current_held_item != null && current_table_in_range != null && current_table_in_range.name.contains("sombraro"):
		current_held_item.add_hat.rpc(Enums.HatType.SOMBRARO)
	elif current_held_item != null && current_table_in_range != null && current_table_in_range.name.contains("cowboy"):
		current_held_item.add_hat.rpc(Enums.HatType.COWBOY)
	elif current_item_in_range != null:
		if current_item_in_range.can_pick_up():
			print("Picked up: " + current_item_in_range.name)
			current_item_in_range.picked_up()
			current_held_item = current_item_in_range
			play_sound.rpc(squish.get_path())
			var path = current_held_item.get_path()
			change_mask.rpc(path, 10, true)
			change_layer.rpc(path, 10, true)
			change_mask.rpc(path, 1, false)
			change_layer.rpc(path, 1, false)
			current_item_in_range = null
	elif current_held_item != null:
		# Drop item
		play_sound.rpc(squish.get_path())
		var path = current_held_item.get_path()
		change_mask.rpc(path, 1, true)
		change_layer.rpc(path, 1, true)
		change_mask.rpc(path, 10, false)
		change_layer.rpc(path, 10, false)
		current_held_item = null

func select_next_order():
	# Auto-select the most urgent remaining order after submitting
	# Pass the submitted number so urgency check excludes it (it's still
	# in OrderManager.orders until the pumpkin physically hits the customer)
	var next = OrderManager.get_most_urgent_order_number()
	if next == -1:
		OrderManager.highlight_order(-1)
	else:
		selected_order = next
		OrderManager.highlight_order(selected_order)

func consume_throw_score_data() -> Dictionary:
	if _throw_order_num == -1:
		return {}
	var data = {"throw_pos": _throw_start_pos, "elapsed": _throw_order_time}
	_throw_order_num = -1
	return data

func set_player_name(n: String):
	player_name.text = n
	if n.is_empty():
		player_name.visible = false

@rpc("any_peer", "call_local")
func turn_in_order(node, order_number):
	var obj = get_node(node)
	obj.set_order_number(order_number)

@rpc("any_peer", "call_local")
func play_sound(node):
	get_node(node).play()

@rpc("any_peer", "call_local")
func change_layer(node, layer, enabled):
	var obj = get_node(node)
	obj.set_collision_layer_value(layer, enabled)

@rpc("any_peer", "call_local")
func change_mask(node, mask, enabled):
	var obj = get_node(node)
	obj.set_collision_mask_value(mask, enabled)

@rpc("any_peer", "call_local")
func delete_pumpkin(path):
	if is_multiplayer_authority():
		get_parent().get_node(path).queue_free()

func get_input():
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if !dead:
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_direction * Enums.player_speed

		if velocity.x > 0:
			sprite.flip_h = false
			facingRight = true
			play_sprite.rpc(sprite.get_path(), true, moving_string)
		elif velocity.x < 0:
			sprite.flip_h = true
			facingRight = false
			play_sprite.rpc(sprite.get_path(), true, moving_string)
		elif velocity.y < 0 || velocity.y > 0:
			play_sprite.rpc(sprite.get_path(), true, moving_string)
		else:
			play_sprite.rpc(sprite.get_path(), true, idle_string)

@rpc("any_peer", "call_local")
func play_sprite(path, play, animation):
	if play:
		get_node(path).play(animation)
	else:
		get_node(path).stop()

func _physics_process(_delta: float) -> void:
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return

	if !dead:
		if !throw_order && current_held_item != null:
			if facingRight:
				move_pumpkin.rpc(current_held_item.get_path(), global_position.x + 10, global_position.y - 5)
			else:
				move_pumpkin.rpc(current_held_item.get_path(), global_position.x - 10, global_position.y - 5)

		if throw_order && is_instance_valid(target_node):
			var direction = (target_node.global_position - current_held_item.global_position).normalized()
			throw_pumpkin.rpc(current_held_item.get_path(), direction)
			throw_order = false
			current_held_item = null

		get_input()
		move_and_slide()

@rpc("any_peer", "call_local")
func move_pumpkin(node, x, y):
	if is_multiplayer_authority() && has_node(node):
		var obj = get_node(node)
		if obj != null:
			obj.global_position.x = x
			obj.global_position.y = y

@rpc("any_peer", "call_local")
func throw_pumpkin(node, direction):
	var obj = get_node(node)
	obj.apply_central_impulse(direction * THROW_SPEED)
	obj.apply_torque_impulse(SPIN_SPEED)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("Entered: ", area.name)

	if area.name.contains("table"):
		current_table_in_range = area.get_parent()
	if area.name.contains("dog_house"):
		current_dog_house_in_range = area.get_parent()
	if area.is_in_group("items"):
		current_item_in_range = area.get_parent()
	if area.is_in_group("cats"):
		current_cat_in_range = area.get_parent()

	if area.name == "ghost_body":
		dead = true
		sprite.stop()
		print("dead!")
		death_timer.start(3)

func display_restart():
	var canvas := CanvasLayer.new()
	canvas.layer = 30
	get_tree().current_scene.add_child(canvas)

	var game_over_menu = GAME_OVER_MENU.instantiate()
	game_over_menu.canvas_layer = canvas
	canvas.add_child(game_over_menu)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_item_in_range:
		current_item_in_range = null
	if area.get_parent() == current_cat_in_range:
		current_cat_in_range = null
	if area.get_parent() == current_table_in_range:
		current_table_in_range = null
	if area.get_parent() == current_dog_house_in_range:
		current_dog_house_in_range = null

func is_dead() -> bool:
	return dead

func _on_death_timer_timeout() -> void:
	display_restart()
	get_tree().paused = true

func set_player_id(id):
	player_id = id
	multiplayer_synchronizer.set_multiplayer_authority(id)

func set_char_select(c: Enums.CharSelection):
	char_select = c
	print("Char set to: ", c)
	sprite.scale = default_sprite_scale
	sprite.position = default_sprite_position

	match char_select:
		Enums.CharSelection.KNIGHT:
			idle_string = "idle"
			moving_string = "moving"
		Enums.CharSelection.WITCH:
			idle_string = "witch_idle"
			moving_string = "witch_moving"
			sprite.scale.x = .4
			sprite.scale.y = .4
		Enums.CharSelection.BLUE_WITCH:
			idle_string = "blue_witch_idle"
			moving_string = "blue_witch_moving"
			sprite.scale.x = .4
			sprite.scale.y = .4
		Enums.CharSelection.SKELETON:
			idle_string = "skeleton_idle"
			moving_string = "skeleton_moving"
			sprite.scale.x = .3
			sprite.scale.y = .3
			sprite.position.y = -10

	sprite.visible = true
	play_sprite.rpc(sprite.get_path(), true, idle_string)
