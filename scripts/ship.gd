class_name Ship

extends CursorNode

enum ROTATION_DIR{LEFT,RIGHT}


@export var DIM:int = 3 
@export var dir:Vector2i = Vector2i(0,-1)

@export var positions: Array[Vector2i] = [Vector2i(4,4),Vector2i(4,5),Vector2i(4,6)]
@export var sprite : Sprite2D 

@export var targetBoard : Board
var positionsHit: Array[Vector2i]
var flames: Array[Sprite2D]

func flip() ->void:
	dir *= -1
	rotation+= PI
	#var offset = dir*-float(DIM-3)*Board.CELL_SIZE
	#print(offset)
	#sprite.translate(offset)

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)

func setPosition(worldPos : Vector2) -> void:
	var cell = targetBoard.world_to_cell(worldPos)
	var cellCenter = Vector2(cell)+Vector2.ONE*0.5 * rotate90(dir,ROTATION_DIR.LEFT) if DIM % 2 == 0 else Vector2(cell)+Vector2.ONE*0.5
	#print(cellCenter)
	global_position = targetBoard.cell_to_world(cellCenter) if targetBoard.isValidPos(cell) else worldPos

func place() -> bool:
	var refPos = targetBoard.world_to_cell(global_position)
	set_state(CursorNode.STATE.PLACED)
	positions = [refPos]
	for i in range(1,DIM+1):
		if i%2==0:
			positions.push_front(refPos + (i/2)*dir)
		else:
			positions.append(refPos - (i/2)*dir)
		
	return positions.all(func(p):return targetBoard.isValidPos(p))

static func rotate90(vec, direction:ROTATION_DIR):
	var rotationMatrix : Transform2D
	if(direction == Ship.ROTATION_DIR.LEFT):
		rotationMatrix.x = Vector2.DOWN
		rotationMatrix.y = Vector2.LEFT
	else:
		rotationMatrix.x = Vector2.UP
		rotationMatrix.y = Vector2.RIGHT
	return rotationMatrix * Vector2(vec)


func rotateShip(direction:ROTATION_DIR) ->void :
	if(direction == ROTATION_DIR.LEFT):
		rotation+= PI/2
	else:
		rotation-= PI/2
	dir = rotate90(dir,direction)
	print(dir)

func positionUpdated():
	var center = positions.reduce(func(a,b):return a+b) /positions.size() 
	global_position = targetBoard.cell_to_world(Vector2(center)+Vector2.ONE*0.5)
	for it in range(0,flames.size()):
		flames[it].global_position = targetBoard.cell_to_world(Vector2(positionsHit[it])+Vector2.ONE*0.5)

func hit(pos: Vector2i, isScan:bool)-> bool :
	var it = positions.find(pos)
	if it != -1:
		if isScan : 
			return true
		var i = positionsHit.find(pos) 
		if i != -1:
			return true
		positionsHit.append(positions[it])
		var sprite = Sprite2D.new()
		sprite.texture = preload("res://art/Flamme.png")
		sprite.z_index = 25
		targetBoard.add_child(sprite)
		sprite.global_position = targetBoard.cell_to_world(Vector2(positions[it])+Vector2.ONE*0.5)
		flames.append(sprite)
		return true
	return false
