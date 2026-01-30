extends Node

@export var cam: Camera2D
@export var board: Board

@export var shipsPlayer1: Array[Ship]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		print(board.world_to_cell(board.get_global_mouse_position()))
		moveShips(shipsPlayer1)
	if event.is_action_pressed("Cancel"):
		if MouseSelection.current_selection != null:
			MouseSelection.deselect()

func _ready() -> void:
	cam.make_current()
	

func move(ship : Ship)-> void:
	var nextPos = ship.positions[0] + ship.dir
	if board.isValidPos(nextPos):
		ship.positions.assign(ship.positions.map(func(p)->Vector2i: return p + ship.dir ))
		board.highlightCells.assign(ship.positions)
	else:
		ship.positions.reverse()
		ship.flip()
	var center = ship.positions.reduce(func(a,b):return a+b) /ship.positions.size() 
	ship.position = board.cell_to_world(Vector2(center)+Vector2.ONE*0.5)

func moveShips(ships : Array[Ship]) -> void:
	for ship in ships:
		move(ship)
