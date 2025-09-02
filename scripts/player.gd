extends CharacterBody2D

const SPEED = 130.0
const THROW_SPEED = 300
const SPIN_SPEED = 2000

@onready var throw: AudioStreamPlayer2D = $throw
@onready var squish: AudioStreamPlayer2D = $squish
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $death_timer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var player_name: Label = $Panel/name

var current_item_in_range:RigidBody2D = null
var current_held_item: RigidBody2D = null
var current_cat_in_range: StaticBody2D = null
var facingRight = true
var target_node = null
var throw_order = false
var dead = false
var player_id

func _input(event):
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	if !dead:
		if event.is_pressed() && event.as_text() == "1" || event.as_text() == "2" || event.as_text() == "3" || event.as_text() == "4" || event.as_text() == "5":
			var order = OrderManager.get_order(int(event.as_text()))
			if order != null && current_held_item != null:
					var num = int(event.as_text())
					target_node = order.get_customer()
					turn_in_order.rpc(current_held_item.get_path(), num)
					print("have it!")
					play_sound.rpc(throw.get_path())
					#target_node = OrderManager.remove_order(num)
					#OrderManager.remove_order.rpc(num)
					current_held_item.set_customer(target_node)
					current_held_item.lock_rotation = false
					throw_order = true
		
		if event.is_action_pressed("interact"):
			if current_cat_in_range != null && current_held_item != null && !current_held_item.name.contains("jack") && !current_cat_in_range.is_busy():
				# give pumpkin to cat
				print("gave pumpkin to cat!")
				squish.play()
				current_cat_in_range.carve.rpc()
				delete_pumpkin.rpc(current_held_item.get_path())
				current_cat_in_range = null
				
			elif current_item_in_range != null:
				if current_item_in_range.can_pick_up():
					# Perform pickup logic here
					print("Picked up: " + current_item_in_range.name)
					current_item_in_range.picked_up()
					current_held_item = current_item_in_range
					play_sound.rpc(squish.get_path())
					
					#ignore collision on object when picked up
					var path = current_held_item.get_path()
					change_mask.rpc(path, 10, true)
					change_layer.rpc(path, 10, true)
					change_mask.rpc(path, 1, false)
					change_layer.rpc(path, 1, false)
					
					current_item_in_range = null
					
			elif current_held_item != null:
				#drop item
				play_sound.rpc(squish.get_path())
				var path = current_held_item.get_path()
				change_mask.rpc(path, 1, true)
				change_layer.rpc(path, 1, true)
				change_mask.rpc(path, 10, false)
				change_layer.rpc(path, 10, false)
				
				#uncomment to have pumpkins die when dropped
				#current_held_item.death()
				current_held_item = null

func set_player_name(n:String):
	player_name.text = n

@rpc("any_peer", "call_local")
func turn_in_order(node, order_number):
	var obj = get_node(node)
	obj.set_order_number(order_number)

@rpc("any_peer","call_local")
func play_sound(node):
	get_node(node).play()

@rpc("any_peer","call_local")
func change_layer(node, layer, enabled):
	var obj = get_node(node)
	obj.set_collision_layer_value(layer, enabled)
	
@rpc("any_peer","call_local")
func change_mask(node, mask, enabled):
	var obj = get_node(node)
	obj.set_collision_mask_value(mask, enabled)

@rpc("any_peer","call_local")
func delete_pumpkin(path):
	get_parent().get_node(path).queue_free()

func get_input():
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	if !dead:
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = input_direction * SPEED
			
		if velocity.x > 0:
			sprite.flip_h = false # Face right
			facingRight = true
			sprite.play("moving")
		elif velocity.x < 0:
			sprite.flip_h = true  # Face left
			facingRight = false
			sprite.play("moving")
		elif velocity.y < 0 || velocity.y > 0:
			sprite.play("moving")
		else:
			sprite.pause()
		
func _physics_process(_delta: float) -> void:
	if multiplayer_synchronizer.get_multiplayer_authority() != multiplayer.get_unique_id():
		return
		
	if !dead:
		if !throw_order && current_held_item != null:
			if facingRight:
				move_pumpkin.rpc(current_held_item.get_path(), global_position.x + 10, global_position.y - 5)
				#current_held_item.global_position.x = global_position.x + 10
				#current_held_item.global_position.y = global_position.y - 5
			else:
				move_pumpkin.rpc(current_held_item.get_path(), global_position.x - 10, global_position.y - 5)
				#current_held_item.global_position.x = global_position.x - 10
				#current_held_item.global_position.y = global_position.y - 5
			
		if throw_order && is_instance_valid(target_node):
			# Calculate the direction from the item to the target
			var direction = (target_node.global_position - current_held_item.global_position).normalized()
			
			throw_pumpkin.rpc(current_held_item.get_path(), direction)
			
			## Apply a continuous force in that direction
			#current_held_item.apply_central_impulse(direction * 400)
			#current_held_item.apply_torque_impulse(2000)
			throw_order = false
			current_held_item = null
			
		get_input()
		move_and_slide()
		
@rpc("any_peer","call_local")
func move_pumpkin(node, x, y):
	var obj = get_node(node)
	obj.global_position.x = x
	obj.global_position.y = y
	
@rpc("any_peer","call_local")	
func throw_pumpkin(node, direction):
	var obj = get_node(node)
	obj.apply_central_impulse(direction * THROW_SPEED)
	obj.apply_torque_impulse(SPIN_SPEED)
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("items"): # Assuming items are in an "items" group
		print("area ", area.get_parent())
		print("area ", area.get_parent().name)
		current_item_in_range = area.get_parent()
	if area.is_in_group("cats"): # Assuming items are in an "items" group
		print("area " + area.get_parent().name)
		current_cat_in_range = area.get_parent()
		
	if area.name == "ghost_body":
		dead = true
		sprite.play("death")
		print("dead!")
		death_timer.start(3)
		
		
func display_restart():
	get_parent().get_node("restart").visible = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() == current_item_in_range:
		current_item_in_range = null
	if area.get_parent() == current_cat_in_range:
		current_cat_in_range = null

func is_dead() -> bool:
	return dead

func _on_death_timer_timeout() -> void:
	display_restart()
	get_tree().paused = true

func set_player_id(id):
	player_id = id
	multiplayer_synchronizer.set_multiplayer_authority(id)
