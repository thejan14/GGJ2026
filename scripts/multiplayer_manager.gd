extends Node

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id: int, info: Dictionary)
signal player_disconnected(peer_id)
signal server_disconnected
signal ready_update()
signal action_applied(pos: Vector2i, mask: Array[PackedInt32Array])
signal action_result(result: Array[PackedInt32Array])

const PORT = 28960
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

var client_player_id: int

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name", "ready": false}

var players_loaded = 0

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func join_game(address: String, player_name: String):
	player_info["name"] = player_name
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game(player_name: String):
	player_info["name"] = player_name
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	players[1] = player_info
	player_connected.emit(1, player_info)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

@rpc("any_peer", "call_local", "reliable")
func notify_ready(is_ready: bool) -> void:
	print("%s ready: %s" % [multiplayer.get_remote_sender_id(), is_ready])
	players[multiplayer.get_remote_sender_id()].ready = is_ready
	ready_update.emit()

@rpc("any_peer", "reliable")
func apply_action_mask(pos: Vector2i, mask: Array[PackedInt32Array]) -> void:
	action_applied.emit(pos, mask)

@rpc("any_peer", "reliable")
func notify_action_result(result: Array[PackedInt32Array]) -> void:
	action_result.emit(result)

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	if multiplayer.is_server():
		client_player_id = new_player_id
	else:
		client_player_id = multiplayer.get_unique_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print("Successfully registerd player: %s" % new_player_id)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
