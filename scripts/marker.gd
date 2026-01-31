class_name Marker

extends CursorNode

var targetBoard : Map

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)

func setPosition(worldPos : Vector2)-> void:
	var cell = targetBoard.world_to_cell(worldPos)
	global_position = targetBoard.cell_to_world(cell) if targetBoard.isValidPos(cell) else worldPos

func place() -> bool:
	return true
