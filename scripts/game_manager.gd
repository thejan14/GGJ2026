extends Node

enum GAME_STATE
{
	SETUP,
	ENEMY_TURN,
	PLAYER_TURN,
}

@export var cam: Camera2D
@export var board: Board
@export var tool_bar: Control
@export var objects_container: Control

@export var shipsPlayer1: Array[Ship]

var current_state: GAME_STATE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		moveShips(shipsPlayer1)
		if  MouseSelection.current_selection is Ship:
			var ship : Ship = MouseSelection.current_selection
			ship.place()
			shipsPlayer1.append(ship)
			ship.reparent(board)
			MouseSelection.current_selection = null
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
	set_state(GAME_STATE.SETUP)
	cam.make_current()

func set_state(state: GAME_STATE) -> void:
	current_state = state
	tool_bar.visible = current_state == GAME_STATE.PLAYER_TURN
	objects_container.visible = current_state == GAME_STATE.SETUP

func isfree(pos : Vector2i) -> bool :
	return !shipsPlayer1.any(func(ship:Ship):return ship.positions.any(func(p:Vector2i):return p == pos))

func move(ship : Ship)-> void:
	var nextPos = ship.positions[0] + ship.dir
	if board.isValidPos(nextPos) && isfree(nextPos):
		ship.positions.assign(ship.positions.map(func(p)->Vector2i: return p + ship.dir ))
		board.highlightCells.assign(ship.positions)
	else:
		ship.positions.reverse()
		ship.flip()
	var center = ship.positions.reduce(func(a,b):return a+b) /ship.positions.size() 
	ship.global_position = board.cell_to_world(Vector2(center)+Vector2.ONE*0.5)

func moveShips(ships : Array[Ship]) -> void:
	for ship in ships:
		move(ship)
