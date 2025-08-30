extends Sprite2D

@onready var grow: Timer = $grow
const PUMPKIN = preload("res://scenes/pumpkin.tscn")
var current_pumpkin = null

enum GrowState {
	SEED,
	SPROUT,
	PARTIAL,
	FULL
}

var grow_state = GrowState.SEED

func _on_grow_timeout() -> void:
	grow_pumpkin.rpc()
	
@rpc("any_peer","call_local")
func grow_pumpkin():
	grow_state = (grow_state + 1) as GrowState

	match grow_state:
		GrowState.SEED:
			pass
		GrowState.SPROUT:
			current_pumpkin = PUMPKIN.instantiate()
			print("instance: ", current_pumpkin.name)
			current_pumpkin.global_position.x = global_position.x
			current_pumpkin.global_position.y = global_position.y + 1
			get_parent().add_child(current_pumpkin, true)
			current_pumpkin.attach_patch(self)
			current_pumpkin.get_node("pumpkin_good").scale *= .33
		GrowState.PARTIAL:
			current_pumpkin.get_node("pumpkin_good").scale *= 2
		GrowState.FULL:
			current_pumpkin.get_node("pumpkin_good").scale *= 1.25
			current_pumpkin.set_can_pick_up()
			grow_state = GrowState.SEED
			grow.stop()

func on_picked():
	print("picked!")
	grow.start()
