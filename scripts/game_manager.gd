class_name GameManager

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

signal state_changed(new_state: GAME_STATE)
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
@export var islands: Array[Vector2i]

var current_state: GAME_STATE
var random = RandomNumberGenerator.new()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		if  MouseSelection.current_selection is Ship:
			var ship : Ship = MouseSelection.current_selection
			if ship.place() && ship.positions.all(func(p): return isfree(p)):
				_ships.append(ship)
				ship.reparent(board)
				MouseSelection.current_selection = null
		if MouseSelection.current_selection is ActionMask:
			var action_mask: ActionMask = MouseSelection.current_selection
			if action_mask.place():
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
	placeIslands()
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
	MultiplayerManager.notify_advance_state.rpc()

func _on_advance_state() -> void:
	MouseSelection.deselect()
	moveShips(_ships)
	if current_state == GAME_STATE.PLAYER_TURN:
		set_state(GAME_STATE.ENEMY_TURN)
	else:
		set_state(GAME_STATE.PLAYER_TURN)

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
	state_changed.emit(current_state)
	for child in tool_bar.find_children("*", "ActionButton", true):
		if child is ActionButton:
			child.disabled = state != GAME_STATE.PLAYER_TURN
			child.modulate = Color(Color.WHITE, 0.4) if child.disabled else Color(Color.WHITE, 1.0)

func isShipOnCell(pos : Vector2i) -> bool :
	if _ships.is_empty():
		return false
	for ship in _ships: 
		for positions in ship.positions:
			if  positions == pos:
				return true
	return false

func isIslandOnCell(pos : Vector2i) -> bool :
	if islands.is_empty():
		return false
	return islands.any(func(p:Vector2i):return p == pos)

func isfree(pos : Vector2i) -> bool :
	return !isShipOnCell(pos) && !isIslandOnCell(pos)

func move(ship : Ship)-> void:
	var nextPos = ship.positions[0] + ship.dir
	if board.isValidPos(nextPos) && isfree(nextPos):
		ship.positions.assign(ship.positions.map(func(p)->Vector2i: return p + ship.dir ))
		ship.positionsHit.assign(ship.positionsHit.map(func(p)->Vector2i: return p + ship.dir ))
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
			if ship.hit(pos,action == ActionMask.ACTION.SCAN):
				return RESULT.SHIP_HIT if action == ActionMask.ACTION.HIT else RESULT.SHIP
		if bojen.find(pos) != -1 || islands.find(pos) != -1:
			return RESULT.OBJECT
	return RESULT.WATER

func placeIslands():
	# 2x2
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://art/Inselgruppe_4.png")
	sprite.z_index = 1
	board.add_child(sprite)
	var pos = Vector2i(random.randi_range(2,board.DIM-2),random.randi_range(2,board.DIM-2))
	sprite.global_position = board.cell_to_world(pos)+ Vector2(40,40)
	var positions : Array[Vector2i] = [pos, pos+Vector2i.RIGHT, pos+Vector2i.DOWN, pos+Vector2i.ONE] 
	islands.append_array(positions)
	board.highlightCells.assign(islands)
	
	## 2x3
	#var sprite23 = Sprite2D.new()
	#sprite23.texture = preload("res://art/Inselgruppe_4.png")
	#sprite23.z_index = 1
	#board.add_child(sprite23)
	#var pos23 = Vector2i(random.randi_range(2,board.DIM-2),random.randi_range(2,board.DIM-2))
	#sprite23.global_position = board.cell_to_world(pos)+ Vector2(40,40)
	#var positions23 : Array[Vector2i] = [pos, pos+Vector2i.RIGHT, pos+Vector2i.DOWN, pos+Vector2i.ONE,pos+Vector2i.DOWN+Vector2i.DOWN, pos+Vector2i.ONE+Vector2i.DOWN] 
	#while !(positions23.all(func(p): return isfree(p))):
		#pos23 = Vector2i(random.randi_range(2,board.DIM-2),random.randi_range(2,board.DIM-2))
		#sprite23.global_position = board.cell_to_world(pos)+ Vector2(40,40)
		#positions23 = [pos, pos+Vector2i.RIGHT, pos+Vector2i.DOWN, pos+Vector2i.ONE,pos+Vector2i.DOWN+Vector2i.DOWN, pos+Vector2i.ONE+Vector2i.DOWN] 
	#
	#islands.append_array(positions)
	#board.highlightCells.assign(islands)
