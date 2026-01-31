extends Node

enum GAME_STATE
{
	SETUP,
	ENEMY_TURN,
	PLAYER_TURN,
}

enum RESULT
{
	NO_RESULT = 0,
	WATER = 1,
	OBJECT = 2,
	SHIP = 3,
	SHIP_HIT = 4
}


@export var cam: Camera2D
@export var board: Board
@export var map: Map
@export var result_info: ResultInfo
@export var tool_bar: Control
@export var objects_container: Control
@export var ready_info: Control
@export var ready_button: Button
@export var host_name: Label
@export var client_name: Label
@export var host_ready: CheckBox
@export var client_ready: CheckBox
@export var board_target: Marker2D
@export var map_target: Marker2D

@export var _ships: Array[Ship]
@export var bojen: Array[Ship]
@export var ilands: Array[Ship]

var current_state: GAME_STATE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		moveShips(_ships)
		if  MouseSelection.current_selection is Ship:
			var ship : Ship = MouseSelection.current_selection
			if ship.place() && ship.positions.all(func(p): return isfree(p)):
				_ships.append(ship)
				ship.reparent(board)
				MouseSelection.current_selection = null
		if MouseSelection.current_selection is ActionMask:
			var action_mask: ActionMask = MouseSelection.current_selection
			action_mask.place()
			MouseSelection.deselect()
	if event.is_action_pressed("RotateDown"):
		if  MouseSelection.current_selection is Ship:
			var ship : Ship = MouseSelection.current_selection
			ship.rotateShip(Ship.ROTATION_DIR.LEFT)
	if event.is_action_pressed("RotateUp"):
		if  MouseSelection.current_selection is Ship:
			var ship : Ship = MouseSelection.current_selection
			ship.rotateShip(Ship.ROTATION_DIR.RIGHT)
	if event.is_action_pressed("Cancel"):
		if MouseSelection.current_selection != null:
			MouseSelection.deselect()

func _ready() -> void:
	if MultiplayerManager.players.size() > 0:
		host_name.text = MultiplayerManager.players[1].name
		client_name.text = MultiplayerManager.players[MultiplayerManager.client_player_id].name
	else:
		MultiplayerManager.create_game("Test")
		client_ready.button_pressed = true
	MultiplayerManager.ready_update.connect(_on_ready_update.bind())
	MultiplayerManager.action_applied.connect(_on_action_applied.bind())
	MultiplayerManager.action_result.connect(_on_action_result.bind())
	MultiplayerManager.advance_state.connect(_on_advance_state.bind())
	ready_button.pressed.connect(player_ready.bind())
	set_state(GAME_STATE.SETUP)
	cam.make_current()
	if not Engine.is_editor_hint():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _on_action_applied(pos: Vector2i, mask: Array[PackedInt32Array]) -> void:
	print("Action applied at: %s, %s" % [pos, mask])
	var result := apply_action_mask(pos, mask)
	var id = MultiplayerManager.client_player_id if multiplayer.is_server() else 1
	MultiplayerManager.notify_action_result.rpc_id(id, result)

func _on_action_result(result: Array[PackedInt32Array]) -> void:
	print("Result received: %s" % [result])
	result_info.set_result(result)

func _on_advance_state() -> void:
	MouseSelection.deselect()
	if current_state == GAME_STATE.PLAYER_TURN:
		current_state = GAME_STATE.ENEMY_TURN
	else:
		current_state = GAME_STATE.PLAYER_TURN

func _on_ready_update() -> void:
	var all_ready: bool = true
	for id in MultiplayerManager.players.keys():
		var is_ready = MultiplayerManager.players[id].ready
		all_ready = all_ready and is_ready
		if id == 1:
			host_ready.button_pressed = is_ready
		else:
			client_ready.button_pressed = is_ready
	if all_ready:
		transition_to_turn_state()

func transition_to_turn_state() -> void:
	map.process_mode = Node.PROCESS_MODE_INHERIT
	map.visible = true
	ready_info.visible = false
	objects_container.visible = false
	var tween = create_tween()
	tween.parallel().tween_property(board, "transform", board_target.transform, 1.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(map, "transform", map_target.transform, 1.0) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	tool_bar.visible = true
	result_info.visible = true
	set_state(GAME_STATE.PLAYER_TURN if multiplayer.is_server() else GAME_STATE.ENEMY_TURN)

func player_ready() -> void:
	MultiplayerManager.notify_ready.rpc(true)

func set_state(state: GAME_STATE) -> void:
	current_state = state

func isfree(pos : Vector2i) -> bool :
	return !_ships.any(func(ship:Ship):return ship.positions.any(func(p:Vector2i):return p == pos))

func move(ship : Ship)-> void:
	var nextPos = ship.positions[0] + ship.dir
	if board.isValidPos(nextPos) && isfree(nextPos):
		ship.positions.assign(ship.positions.map(func(p)->Vector2i: return p + ship.dir ))
		board.highlightCells.assign(ship.positions)
	else:
		ship.positions.reverse()
		ship.flip()
	ship.positionUpdated()

func moveShips(ships : Array[Ship]) -> void:
	for ship in ships:
		move(ship)

func apply_action_mask(pos: Vector2i, mask: Array[PackedInt32Array]) -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = []
	for j in range(0, mask.size()):
		result.push_back([])
		for i in range(0, mask[j].size()):
			var board_pos := pos + Vector2i(i, j)
			result[j].push_back(get_action_result(board_pos, mask[j][i]))
	return result

func get_action_result(pos: Vector2i, action: ActionMask.ACTION) -> RESULT:
	if action == ActionMask.ACTION.EMPTY:
		return RESULT.NO_RESULT
	else:
		for ship in _ships:
			if ship.hit(pos):
				return RESULT.SHIP_HIT if action == ActionMask.ACTION.HIT else RESULT.SHIP
		if bojen.find(pos) != -1 || ilands.find(pos) != -1:
			return RESULT.OBJECT
	return RESULT.WATER
