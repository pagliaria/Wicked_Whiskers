extends Control

@export var game: PackedScene
@export var how_to_play_scene: PackedScene
@export var address = "147.185.221.31"
@export var join_port = 38507
@export var port = 10537
@onready var status: Label = $CenterContainer/Panel/status
@onready var my_name: LineEdit = $CenterContainer/Panel/name
@onready var start: Button = $CenterContainer/Panel/start
@onready var char_select_image: Sprite2D = $CenterContainer/Panel/Panel/char_select_image
const KNIGHT = preload("res://assets/sprites/characters/knight.png")
const WITCH_001_SWEN = preload("res://assets/sprites/characters/witch-001-SWEN.png")
const WITCH_002_SWEN = preload("res://assets/sprites/characters/witch-002-SWEN.png")
const SKELETON = preload("res://assets/sprites/characters/elder_skeleton-SWEN.png")
@onready var single_player: Button = $CenterContainer/Panel/single_player

var char_select = Enums.CharSelection.KNIGHT
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
	send_player_info.rpc_id(1, my_name.text, multiplayer.get_unique_id(), char_select)
	
@rpc("any_peer")
func send_player_info(p_name:String, id:int, char: int):
	if !MultiplayerManager.Players.has(id):
		MultiplayerManager.Players[id] = {
			"name" : p_name,
			"id" : id,
			"char" : char
		}
		
	if !players.has(id):
		players[id] = p_name
		for spot in get_tree().get_nodes_in_group("player_spots"):
			if !spot.visible:
				spot.visible  = true
				var name_spot = spot.get_node("player_name")
				var char_spot = spot.get_node("TextureRect")
				name_spot.text = p_name
				set_character(char_spot, char)
				break
		
	if multiplayer.is_server():
		for player in MultiplayerManager.Players:
			send_player_info.rpc(MultiplayerManager.Players[player].name, player, MultiplayerManager.Players[player].char)
	
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
	
	single_player.disabled = true
	
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(port, 4)
	
	if error != OK:
		print("cannt connect: ", error)
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	print("waiting for players...")
	status.text = "Waiting for players..."
	send_player_info(my_name.text, multiplayer.get_unique_id(), char_select)
	start.disabled = false

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, join_port)
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_how_to_play_pressed() -> void:
	var htp = how_to_play_scene.instantiate()
	get_tree().root.add_child(htp)

func _on_single_player_pressed() -> void:
	MultiplayerManager.Players[1] = {
			"name" : my_name.text,
			"id" : 1,
			"char" : char_select
		}
	start_game()


func _on_change_char_pressed() -> void:
	
	var char_size = Enums.CharSelection.size()
	
	char_select += 1
	if char_select > char_size - 1:
		char_select = 0

	set_character(char_select_image, char_select)

func set_character(sprite: Sprite2D, c:Enums.CharSelection):
	match c:
		Enums.CharSelection.KNIGHT:
			sprite.texture = KNIGHT
			sprite.region_rect = Rect2(1, 3, 30, 32)
			sprite.scale.x = 3.3
			sprite.scale.y = 3.3
		Enums.CharSelection.WITCH:
			sprite.texture = WITCH_001_SWEN
			sprite.region_rect = Rect2(97, 76, 47, 55)
			sprite.scale.x = 1.5
			sprite.scale.y = 1.5
		Enums.CharSelection.BLUE_WITCH:
			sprite.texture = WITCH_002_SWEN
			sprite.region_rect = Rect2(97, 76, 47, 55)
			sprite.scale.x = 1.5
			sprite.scale.y = 1.5
		Enums.CharSelection.SKELETON:
			sprite.texture = SKELETON
			sprite.region_rect = Rect2(48, 2, 46, 66)
			sprite.scale.x = 1.5
			sprite.scale.y = 1.5
