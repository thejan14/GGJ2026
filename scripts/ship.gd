class_name Ship

extends CursorNode



const DIM:int = 3 
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

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)

func setPosition(worldPos : Vector2) -> void:
	var cell = targetBoard.world_to_cell(worldPos)
	global_position =  targetBoard.cell_to_world(Vector2(cell)+Vector2.ONE*0.5) if targetBoard.isValidPos(cell) else worldPos
