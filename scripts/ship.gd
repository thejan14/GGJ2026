class_name Ship

extends CursorNode

enum ROTATION_DIR{LEFT,RIGHT}


@export var DIM:int = 3 
@export var dir:Vector2i = Vector2i(0,-1)

@export var positions: Array[Vector2i] = [Vector2i(4,4),Vector2i(4,5),Vector2i(4,6)]
@export var sprite : Sprite2D 

@export var targetBoard : Board

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func flip() ->void:
	dir *= -1
	rotation+= PI
	var offset = dir*-float(DIM-3)*Board.CELL_SIZE
	print(offset)
	sprite.translate(offset)

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)

func setPosition(worldPos : Vector2) -> void:
	var cell = targetBoard.world_to_cell(worldPos)
	global_position = targetBoard.cell_to_world(Vector2(cell)+Vector2.ONE*0.5) if targetBoard.isValidPos(cell) else worldPos

func place() -> bool:
	var refPos = targetBoard.world_to_cell(global_position)
	positions = [refPos + dir,refPos,refPos - dir]
	for i in range(3,DIM):
		positions.append(refPos - (i-2)*dir)
	return positions.all(func(p):return targetBoard.isValidPos(p))

func rotateShip(direction:ROTATION_DIR) ->void :
	var rotationMatrix : Transform2D
	if(direction == ROTATION_DIR.LEFT):
		rotationMatrix.x = Vector2.DOWN
		rotationMatrix.y = Vector2.LEFT
		rotation+= PI/2
	else:
		rotationMatrix.x = Vector2.UP
		rotationMatrix.y = Vector2.RIGHT
		rotation-= PI/2
	dir = rotationMatrix * Vector2(dir)
	print(dir)

func positionUpdated():
	var center = positions.reduce(func(a,b):return a+b) /positions.size() 
	global_position = targetBoard.cell_to_world(Vector2(center)+Vector2.ONE*0.5)
