extends CharacterBody2D

var speed = 30
var rotation_modifier = 0
var direction = Vector2(1, 0) # Start moving right
const DIR_4 = [Vector2.LEFT,Vector2.UP,Vector2.RIGHT,Vector2.DOWN]
var animation: AnimatedSprite2D = null
const COIN = preload("res://scenes/coin.tscn")
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var diretion_timer: Timer = $diretionTimer
@onready var remove_timer: Timer = $remove_timer
@onready var smack: AudioStreamPlayer2D = $smack
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var scream: AudioStreamPlayer2D = $scream
@onready var order_bubble: Sprite2D = $order_bubble
@onready var wrong_label: Label = $wrong_label
@onready var warn_indicator: Label = $warn_indicator

var problems = false
var wrong_order = false
var order_time = null
var attacking = false
var player:CharacterBody2D = null

const ORDER_BUBBLE = preload("res://scenes/order_bubble.tscn")
var bubble_scene_instance = null

var ordered = false
var hit_by_order = false
var hit_item: RigidBody2D = null
var order_number = 0
var order: Order = null
var dog = null
var _urgent := false
var _urgent_pulse_time := 0.0
var pause_time = 0.0

func add_pause_time(time: float):
	pause_time = time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if _urgent && warn_indicator.visible:
		_urgent_pulse_time += delta
		var t: float = (sin(_urgent_pulse_time * 4.0 * TAU) + 1.0) * 0.5
		warn_indicator.modulate = Color(1.0, lerp(0.85, 0.3, t), lerp(0.2, 0.0, t), 1.0)
	if !is_multiplayer_authority():
		return
	
	if !ordered && ray_cast_right.is_colliding():
		diretion_timer.start()
		animation.stop()
		generateOrder()
		
	if ordered:
		progress_bar.value = ((Time.get_unix_time_from_system() - order_time - pause_time) / Enums.ORDER_TIMEOUT_SEC) * 100
		#print("progress: ", progress_bar.value)
		#bubble_scene_instance.global_position.x = global_position.x + 20
		#bubble_scene_instance.global_position.y =global_position.y - 30
		
		if progress_bar.value >= 100 || wrong_order:
			#problems!
			warn_indicator.visible = false
			if !attacking:
				play_sound.rpc(scream.get_path())
				animation.modulate = Color(1, 0, 0, 0.8)
				progress_bar.visible = false
				#bubble_scene_instance.visible = false
				speed = 100
				diretion_timer.stop()
				#set_collision_layer_value(1, false)
				set_collision_mask_value(1, false)
				attacking = true
			else:
				direction = global_position.direction_to(player.global_position)
				play_directional_animation()

	if hit_by_order && hit_item != null:
		rotation = hit_item.rotation
		velocity = hit_item.linear_velocity
		global_position.x = hit_item.global_position.x
		global_position.y = hit_item.global_position.y
	else:
		rotation = rotation_modifier
		velocity = direction * speed

	if dog == null:
		move_and_slide()

func generateOrder():
	print("order")
	#progress_bar.visible = true
	order_time = Time.get_unix_time_from_system()
	
	var order_int
	var hat_int
	if Enums.get_night() == 1:
		order_int = 1
	if Enums.get_night() == 2:
		order_int = randi_range(1, 2)
	if Enums.get_night() == 3:
		order_int = randi_range(1, 3)
		
	hat_int = randi_range(1, 5)
	print("order: ", order_int, " ", hat_int)
	var hat_type
	match hat_int:
		1:
			hat_type = Enums.HatType.NONE
		2:
			hat_type = Enums.HatType.WITCH
		3:
			hat_type = Enums.HatType.CAP
		4:
			hat_type = Enums.HatType.COWBOY
		5:
			hat_type = Enums.HatType.SOMBRARO
	
	match order_int:
		1:
			add_order.rpc(hat_type, Enums.OrderType.HAPPY, self.get_path(), order_time)
		2:
			add_order.rpc(hat_type, Enums.OrderType.ANGRY, self.get_path(), order_time)
		3:
			add_order.rpc(hat_type, Enums.OrderType.SURPRISED, self.get_path(), order_time)
	
	#order_number = OrderManager.add_order(order)
		
	#bubble_scene_instance = ORDER_BUBBLE.instantiate()
	#add_child(bubble_scene_instance)
	#bubble_scene_instance.set_type(order.get_order_type())
	#bubble_scene_instance.set_hat(order.get_order_hat())
	#ordered = true

@rpc("any_peer","call_local")
func add_order(ht:Enums.HatType, it: Enums.OrderType, cust_path: String, time: float):
	order_time = time
	order = Order.new(ht, it, get_node(cust_path), time)
	order_number = OrderManager.add_order(order)
	order_bubble.visible = true
	order_bubble.set_type(order.get_order_type())
	order_bubble.set_hat(order.get_order_hat())
	ordered = true
	#progress_bar.visible = true

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
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name.contains("hell_dog"):
		dog = body
		print("DOG GOT ME!")
		body.killing()
		OrderManager.remove_order.rpc(order_number)
		hit_by_order = true
		order_bubble.visible = false
		problems = false
		set_urgent(false)
		remove_timer.start(2)
		speed = 0
		animation.rotation += deg_to_rad(90)
	
	if !hit_by_order && body.is_in_group("items"):
		#var jack = body as RigidBody2D
		#print("Entered customer: ", body.name, order_number, jack.get_order_number())
		if body.get_order_number() == order_number:
			play_sound.rpc(smack.get_path())
			print("Entered customer: ", body.name)
			diretion_timer.stop()			
			hit_item = body
			progress_bar.visible = false
			if order.get_order_type() != body.getType() || order.get_order_hat() != body.get_hat():
				problems = true
				#set_player.rpc(body.get_player().get_path())
				player = body.get_player()
				show_wrong_feedback.rpc()
			else:
				if is_multiplayer_authority():
					var i = randi_range(3,10)
					spawn_coins.rpc(i)
					Enums.coins_earned_this_night += i
					# Award score based on time remaining and throw distance
					var player_node = body.get_player()
					if player_node != null && player_node.has_method("consume_throw_score_data"):
						var data = player_node.consume_throw_score_data()
						if data.size() > 0:
							const BASE_POINTS = 100
							const MAX_DISTANCE = 400.0
							var time_ratio = clamp(1.0 - (data.elapsed / Enums.ORDER_TIMEOUT_SEC), 0.0, 1.0)
							var dist = data.throw_pos.distance_to(global_position)
							var dist_bonus = clamp(1.0 + (dist / MAX_DISTANCE), 1.0, 2.0)
							var points = int(BASE_POINTS * time_ratio * dist_bonus)
							Enums.score += points
							Enums.score_earned_this_night += points
							print("Score +%d (time: %.2f, dist: %.2f) = %d" % [points, time_ratio, dist_bonus, Enums.score])
				OrderManager.remove_order.rpc(order_number)
				Enums.orders_completed += 1
				var player_node = body.get_player()
				if player_node != null && player_node.has_method("select_next_order"):
					var data = player_node.select_next_order()
				hit_by_order = true
				order_bubble.visible = false
				problems = false
				set_urgent(false)
			remove_timer.start(1)

@rpc("any_peer", "call_local")
func show_wrong_feedback():
	wrong_label.visible = true
	var tween = create_tween()
	var origin = wrong_label.position
	const SHAKE_DIST = 4.0
	const SHAKE_STEP = 0.04
	for _i in range(6):
		tween.tween_property(wrong_label, "position", origin + Vector2(SHAKE_DIST, 0), SHAKE_STEP)
		tween.tween_property(wrong_label, "position", origin + Vector2(-SHAKE_DIST, 0), SHAKE_STEP)
	tween.tween_property(wrong_label, "position", origin, SHAKE_STEP)
	tween.tween_property(wrong_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): wrong_label.visible = false; wrong_label.modulate.a = 1.0)

func set_urgent(active: bool) -> void:
	_urgent = active
	_urgent_pulse_time = 0.0
	warn_indicator.visible = active
	if active:
		warn_indicator.modulate = Color(1.0, 0.85, 0.2, 1.0)

@rpc("any_peer","call_local")
func play_sound(node):
	get_node(node).play()

@rpc("any_peer","call_local")
func spawn_coins(i):
	for c in i:
		var coin_instance = COIN.instantiate()
		get_parent().add_child(coin_instance)
		coin_instance.spawn_coin(self.global_position)

func _on_remove_timer_timeout() -> void:
	if dog != null:
		dog.deactivate()
	remove_timer.stop()
	if hit_item != null:
		hit_item.queue_free()
	if problems:
		wrong_order = true
		Enums.orders_failed += 1
	else:
		if is_multiplayer_authority():
			queue_free()

@rpc("any_peer","call_local")
func set_player(p: String):
	player = get_node(p)

func is_attacking():
	return attacking
