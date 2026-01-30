class_name Board

extends Node2D

const DIM: int = 20
const CELL_SIZE: int = 40

var cells: Array[Array] = []

func _process(delta: float) -> void:
	for row in cells:
		for cell in row:
			var sprite: Sprite2D = cell
			sprite.modulate = Color.WHITE
	var target_cell = world_to_cell(get_global_mouse_position())
	if target_cell.x >= 0 and target_cell.x < DIM and target_cell.y >= 0 and target_cell.y < DIM:
		cells[target_cell.x][target_cell.y].modulate = Color.RED

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

func get_cell(coord: Vector2i) -> Sprite2D:
	if coord.x >= 0 and coord.x < DIM and coord.y >= 0 and coord.y < DIM:
		return cells[coord.x][coord.y]
	else:
		return null

func world_to_cell(pos: Vector2) -> Vector2i:
	var local_pos = to_local(pos)
	return local_pos / CELL_SIZE
