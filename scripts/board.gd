class_name Board

extends Grid

enum RESULT
{
	WATER = 0,
	OBJECT = 1,
	SHIP = 2,
	SHIP_HIT = 3
}


var cells: Array[Array] = []
var highlightCells: Array[Vector2i]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		var cell_pos := world_to_cell(get_global_mouse_position())
		if isValidPos(cell_pos) and MouseSelection.current_selection is Ship:
			pass

func _process(delta: float) -> void:
	for row in cells:
		for cell in row:
			var sprite: Sprite2D = cell
			sprite.modulate = Color(Color.WHITE, 0.4)
	highlight(world_to_cell(get_global_mouse_position()))
	#for cell in highlightCells:
		#highlight(cell)
	

func highlight(target_cell :Vector2i):
	if isValidPos(target_cell):
		cells[target_cell.x][target_cell.y].modulate = Color.RED

func apply_action_mask(pos: Vector2i, mask: Array[PackedInt32Array]) -> Array[PackedInt32Array]:
	var result: Array[PackedInt32Array] = []
	for j in range(0, mask.size()):
		result.push_back([])
		for i in range(0, mask[j].size()):
			var board_pos := pos + Vector2i(i, j)
			result[j].push_back(get_action_result(board_pos, mask[j][i]))
	return result

func get_action_result(pos: Vector2i, action: ActionMask.ACTION) -> RESULT:
	return RESULT.WATER

func _ready() -> void:
	for i in range(0, DIM):
		var row: Array = []
		for j in range(0, DIM):
			var cell := Sprite2D.new()
			cell.position = Vector2(i * CELL_SIZE, j * CELL_SIZE) + (Vector2.ONE * (CELL_SIZE / 2.0))
			cell.texture = preload("uid://d0dksl0vaxqvn")
			add_child(cell)
			row.push_back(cell)
		cells.push_back(row)
