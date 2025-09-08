extends Node2D

@onready var move_timer: Timer = $move_timer
@onready var timer: Timer = $Timer
var move = false
@onready var coin_sound: AudioStreamPlayer2D = $coin_sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if move:
		# Move right at a speed of 100 units per second
		position.x += 100 * delta
		position.y += 100 * delta

		# Move towards a target position
		var target_position = Enums.coin_counter_pos
		var speed = 400
		global_position = global_position.move_toward(target_position, speed * delta)

func spawn_coin(pos):
	self.global_position = pos
	move_timer.start(randf_range(.1, .3))

func _on_timer_timeout() -> void:
	Enums.coins += 1
	coin_sound.play()

func _on_move_timer_timeout() -> void:
	move_timer.stop()
	move = true
	timer.start(1)


func _on_coin_sound_finished() -> void:
	queue_free()
