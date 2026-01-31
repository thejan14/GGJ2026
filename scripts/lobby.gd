extends Node

@export var host_button: Button
@export var connect_button: Button
@export var start_button: Button
@export var ip_input: LineEdit
@export var ip_info: LineEdit
@export var name_input: LineEdit
@export var host_name: Label
@export var client_name: Label

func _ready():
	ip_info.text = "%s" % IP.get_local_addresses()[-1]
	host_button.pressed.connect(create_game.bind())
	connect_button.pressed.connect(join_game.bind())
	start_button.pressed.connect(start_game.bind())
	MultiplayerManager.player_connected.connect(_on_player_connected.bind())

func _on_player_connected(peer_id: int, info: Dictionary) -> void:
	if peer_id == 1:
		host_name.text = info["name"]
	else:
		client_name.text = info["name"]

func join_game():
	MultiplayerManager.join_game(ip_input.text, name_input.text)

func create_game():
	MultiplayerManager.create_game(name_input.text)

func start_game() -> void:
	MultiplayerManager.load_game("res://scenes/game.tscn")
