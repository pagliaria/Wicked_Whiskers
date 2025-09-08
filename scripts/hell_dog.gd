extends CharacterBody2D

var SPEED = 30
@onready var animation: AnimatedSprite2D = $animation
var direction = Vector2(-1, 0) # Start moving left
const DIR_4 = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]
var active = false
var attacking = false
@onready var direction_timer: Timer = $direction_timer
var cust_spawn:Node2D = null
var target = null
var run_back_location
@onready var growl: AudioStreamPlayer2D = $growl
@onready var bark: AudioStreamPlayer2D = $bark

func _process(delta: float) -> void:
	if active && cust_spawn != null && !attacking:
		for child in cust_spawn.get_children():
			if child.name.contains("customer"):
				if child.is_attacking():
					print("ATTACKING!")
					play_sound.rpc(bark.get_path())
					attacking = true
					target = child
					direction_timer.stop()
					set_collision_layer_value(1, false)
					animation.play("run")

func _physics_process(delta: float) -> void:
	
	if attacking:
		## Move right at a speed of 100 units per second
		#position.x += 100 * delta
		#position.y += 100 * delta

		# Move towards a target position
		if target != null:
			var speed = 200
			global_position = global_position.move_toward(target.global_position, speed * delta)
			if global_position.direction_to(target.global_position).x > 0:
				animation.flip_h = true
			else:
				animation.flip_h = false
		else:
			attacking = false
			direction_timer.start(2)
			set_collision_layer_value(1, false)
			set_collision_mask_value(1, false)
			animation.play("walk")
			active = false
	
	if active:
		move_and_slide()

func _on_direction_timer_timeout() -> void:
	#print("timeout")
	if !active:
		return
	
	set_collision_mask_value(1, true)
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	play_animation(direction)
	
	if randi_range(0, 1) == 1:
		SPEED = 30
		animation.play("walk")
	else:
		SPEED = 0
		animation.play("idle")
		
	velocity = direction * SPEED

func play_animation(dir):
	if dir.x > 0:
		animation.flip_h = true # Face right
		animation.play("walk")
		#sprite.play(moving_string)
	elif dir.x < 0:
		animation.flip_h = false  # Face left
		animation.play("walk")
	elif dir.y < 0 || dir.y > 0:
		animation.play("walk")
	else:
		animation.play("idle")
	
	if randi_range(0, 1) == 1:
		SPEED = 30
		animation.play("walk")
	else:
		SPEED = 0
		animation.play("idle")

func _on_ready() -> void:
	run_back_location = self.global_position

func deactivate():
	self.z_index = 2
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	global_position.x = 323
	global_position.y = 177
	animation.play("idle")
	print("deactivate dog")
	active = false	
	attacking = false
	animation.flip_h = false
	direction_timer.stop()

@rpc("any_peer","call_local")
func activate():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	growl.play()
	direction = Vector2(-1, 0)
	velocity = direction * SPEED
	animation.play("walk")
	print("activate dog")
	active = true	

func set_customer_spawn_point(node):
	cust_spawn = node

func is_active():
	return active

func killing():
	self.z_index = 6
	animation.play("jump")


func _on_dog_area_area_exited(area: Area2D) -> void:
	print("Dog Exited: ", area.name)
	if area.name.contains("dog_house_area"):
		direction_timer.start(2)

@rpc("any_peer","call_local")
func play_sound(node):
	#print("squish! ", node)
	get_node(node).play()
