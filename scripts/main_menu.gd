extends Control

@export var game: PackedScene
@export var address = "147.185.221.31"
@export var join_port = 38507
@export var port = 10537
@onready var status: Label = $CenterContainer/Panel/status
@onready var my_name: LineEdit = $CenterContainer/Panel/name
@onready var start: Button = $CenterContainer/Panel/start

var players = {}
var peer

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.server_disconnected.connect(disconnected_from_server)
	multiplayer.connection_failed.connect(connection_failed)

func peer_connected(id):
	print("player connected ", id)
	
func peer_disconnected(id):
	print("player disconnected ", id)
	
func connected_to_server():
	print("connected to server")
	send_player_info.rpc_id(1, my_name.text, multiplayer.get_unique_id())
	
@rpc("any_peer")
func send_player_info(p_name:String, id:int):
	if !MultiplayerManager.Players.has(id):
		MultiplayerManager.Players[id] = {
			"name" : p_name,
			"id" : id,
			"score" : 0
		}
		
	if !players.has(id):
		players[id] = p_name
		for spot in get_tree().get_nodes_in_group("player_spots"):
			if !spot.visible:
				spot.visible  = true
				var name_spot = spot.get_node("player_name")
				name_spot.text = p_name
				break
		
	if multiplayer.is_server():
		for player in MultiplayerManager.Players:
			send_player_info.rpc(MultiplayerManager.Players[player].name, player)
	
func disconnected_from_server():
	print("disconnected from server")
	
func connection_failed():
	print("connection failed")

@rpc("any_peer", "call_local")
func start_game():
	#get_tree().root.add_child(game.instantiate())
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	self.hide()

func _on_start_pressed() -> void:
	start_game.rpc()

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(port, 4)
	
	if error != OK:
		print("cannt connect: ", error)
		return
	#peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	print("waiting for players...")
	status.text = "Waiting for players..."
	send_player_info(my_name.text, multiplayer.get_unique_id())
	start.disabled = false

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, join_port)
	#peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_single_player_pressed() -> void:
	MultiplayerManager.Players[1] = {
			"name" : my_name.text,
			"id" : 1,
			"score" : 0
		}
	start_game()
