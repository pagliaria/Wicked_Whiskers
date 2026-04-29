extends Control

signal multiplayer_started

@export var difficulty_select_scene: PackedScene

@export var address = "147.185.221.31"
@export var join_port = 38507
@export var port = 10537

@onready var status: Label = $Panel/VBox/status
@onready var name_input: LineEdit = $Panel/VBox/NameRow/name
@onready var start_btn: Button = $Panel/VBox/BottomRow/StartCenter/start
@onready var player_slots: HBoxContainer = $Panel/VBox/PlayerSlots

const KNIGHT = preload("res://assets/sprites/characters/knight.png")
const WITCH_001_SWEN = preload("res://assets/sprites/characters/witch-001-SWEN.png")
const WITCH_002_SWEN = preload("res://assets/sprites/characters/witch-002-SWEN.png")
const SKELETON = preload("res://assets/sprites/characters/elder_skeleton-SWEN.png")

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
	send_player_info.rpc_id(1, name_input.text, multiplayer.get_unique_id())

@rpc("any_peer")
func send_player_info(p_name: String, id: int):
	if !MultiplayerManager.Players.has(id):
		MultiplayerManager.Players[id] = {
			"name": p_name,
			"id": id,
			"char": Enums.CharSelection.KNIGHT
		}

	if !players.has(id):
		players[id] = p_name
		for spot in player_slots.get_children():
			if !spot.visible:
				spot.visible = true
				spot.get_node("player_name").text = p_name
				break

	if multiplayer.is_server():
		for player in MultiplayerManager.Players:
			send_player_info.rpc(
				MultiplayerManager.Players[player].name,
				player
			)

func disconnected_from_server():
	print("disconnected from server")

func connection_failed():
	print("connection failed")

@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 4)
	if error != OK:
		print("cannot connect: ", error)
		return
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	status.text = "Waiting for players..."
	send_player_info(name_input.text, multiplayer.get_unique_id())
	start_btn.disabled = false

func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, join_port)
	peer.host.compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = peer
	status.text = "Joining..."

func _on_start_pressed() -> void:
	var popup = difficulty_select_scene.instantiate()
	get_tree().root.add_child(popup)
	popup.difficulty_chosen.connect(func(): start_game.rpc())

func _on_close_pressed() -> void:
	if peer:
		multiplayer.multiplayer_peer = null
		peer = null
	MultiplayerManager.Players.clear()
	players.clear()
	queue_free()
