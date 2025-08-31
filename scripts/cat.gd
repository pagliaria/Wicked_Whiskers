extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var timer = $Timer
@onready var happy: TextureRect = $happy
@onready var angry: TextureRect = $angry
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var surprised: TextureRect = $surprised

var cutting: AudioStreamPlayer2D = null
var type = Enums.OrderType.INVALID

@rpc("any_peer","call_local")
func carve():
	sprite.play("carving")
	timer.start(5)
	cutting.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.play("idle")
	cutting = $cutting
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
@rpc("any_peer", "call_local")
func set_type(t: Enums.OrderType):
	print("type: ", t)
	if t == Enums.OrderType.HAPPY:
		type = Enums.OrderType.HAPPY
		happy.visible = true
	if t == Enums.OrderType.ANGRY:
		type = Enums.OrderType.ANGRY
		angry.visible = true
		animated_sprite_2d.modulate = Color(1, 0, 0, 1)
	if t == Enums.OrderType.SURPRISED:
		type = Enums.OrderType.SURPRISED
		surprised.visible = true
		animated_sprite_2d.modulate = Color(0, 1, 0, 1)
	
func _on_timer_timeout() -> void:
	sprite.play("idle")
	cutting.stop()
	timer.stop()
	var jack_scene = preload("res://scenes/jack.tscn")
	var jack_scene_instance = jack_scene.instantiate()
	jack_scene_instance.global_position = Vector2(global_position.x - 15, global_position.y - 5)
	get_parent().add_child(jack_scene_instance, true)
	jack_scene_instance.setType(type)
