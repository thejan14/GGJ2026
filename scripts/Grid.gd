class_name Grid

extends Node2D

const DIM: int = 20
const CELL_SIZE: int = 40

func isValidPos(coord: Vector2i) -> bool:
	return coord.x >= 0 and coord.x < DIM and coord.y >= 0 and coord.y < DIM

func world_to_cell(pos: Vector2) -> Vector2i:
	var local_pos = to_local(pos)
	return local_pos / CELL_SIZE

func cell_to_world(pos: Vector2) -> Vector2:
	return to_global(pos*CELL_SIZE)
