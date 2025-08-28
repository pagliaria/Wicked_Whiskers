extends CharacterBody2D

var speed = 30
var rotation_modifier = 0
var direction = Vector2(1, 0) # Start moving right
const DIR_4 = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]
var animation: AnimatedSprite2D = null
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var diretion_timer: Timer = $diretionTimer
@onready var remove_timer: Timer = $remove_timer
@onready var smack: AudioStreamPlayer2D = $smack
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var scream: AudioStreamPlayer2D = $scream

var problems = false
var wrong_order = false
var order_time = null
var attacking = false

const ORDER_BUBBLE = preload("res://scenes/order_bubble.tscn")
var bubble_scene_instance = null

var ordered = false
var hit_by_order = false
var hit_item: RigidBody2D = null
var order_number = 0
var order: Order = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if !ordered && ray_cast_right.is_colliding():
		diretion_timer.start()
		animation.stop()
		generateOrder()
		
	if ordered:
		progress_bar.value = ((Time.get_unix_time_from_system() - order_time) / Enums.ORDER_TIMEOUT_SEC) * 100
		#print("progress: ", progress_bar.value)
		bubble_scene_instance.global_position.x = position.x + 20
		bubble_scene_instance.global_position.y = position.y - 30
		
		if progress_bar.value >= 100 || wrong_order:
			#problems!
			if !attacking:
				scream.play()
				animation.modulate = Color(1, 0, 0, 0.8)
				progress_bar.visible = false
				bubble_scene_instance.visible = false
				speed = 100
				diretion_timer.stop()
				#set_collision_layer_value(1, false)
				set_collision_mask_value(1, false)
				attacking = true
			else:
				direction = global_position.direction_to(get_parent().get_node("Player").global_position)
				play_directional_animation()

	if hit_by_order && hit_item != null:
		rotation = hit_item.rotation
		velocity = hit_item.linear_velocity
		global_position.x = hit_item.global_position.x
		global_position.y = hit_item.global_position.y
	else:
		rotation = rotation_modifier
		velocity = direction * speed

	move_and_slide()

func generateOrder():
	print("order")
	progress_bar.visible = true
	order_time = Time.get_unix_time_from_system()
	
	var rand_int
	if Enums.get_night() == 1:
		rand_int = 1
	if Enums.get_night() == 2:
		rand_int = randi_range(1, 2)
	if Enums.get_night() == 3:
		rand_int = randi_range(1, 3)
		
	match rand_int:
		1:
			order = Order.new(Enums.OrderType.HAPPY, self, order_time)
		2:
			order = Order.new(Enums.OrderType.ANGRY, self, order_time)
		3:
			order = Order.new(Enums.OrderType.SURPRISED, self, order_time)
			
	order_number = OrderManager.add_order(order)
		
	#TODO load different scenes for different orders or call scene and change icon
	bubble_scene_instance = ORDER_BUBBLE.instantiate()
	add_child(bubble_scene_instance)
	bubble_scene_instance.set_type(order.get_order_type())
	ordered = true

func _on_timer_timeout() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	play_directional_animation()

	if randi_range(0, 1) == 1:
		speed = 30
	else:
		speed = 0
		animation.stop()

func play_directional_animation():
	var direction_id = int(round(direction.angle() / TAU * DIR_4.size()))
	#print("direction: ", direction_id)
	match direction_id:
		-2:
			animation.play("walk_left")
		0:
			animation.play("walk_right")
		-1:
			animation.play("walk_up")
		1:
			animation.play("walk_down")

func _on_ready() -> void:
	animation = $ghost
	animation.play("walk_right")

func on_order_complete():
	print("Thanks!")
	#queue_free()
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	#if !hit_by_order && body.name.contains("jack"):
	if !hit_by_order && body.is_in_group("items"):
		#var jack = body as RigidBody2D
		#print("Entered customer: ", body.name, order_number, jack.get_order_number())
		if body.get_order_number() == order_number:
			smack.play()
			bubble_scene_instance.visible = false
			print("Entered customer: ", body.name)
			diretion_timer.stop()
			hit_by_order = true
			progress_bar.visible = false
			hit_item = body
			if order.get_order_type() != body.getType():
				problems = true
			remove_timer.start(2)

func _on_remove_timer_timeout() -> void:
	remove_timer.stop()
	if hit_item != null:
		hit_item.queue_free()
	if problems:
		wrong_order = true
	else:
		queue_free()
