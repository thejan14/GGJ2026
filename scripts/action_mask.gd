class_name ActionMask

extends CursorNode

enum ACTION
{
	EMPTY = 0,
	SCAN = 1,
	HIT = 2
}

@export var target_map: Map
@export var mask: Array[PackedInt32Array] = [
	[0, 0, 0],
	[0, 0, 0],
	[0, 0, 0],
]

func setPosition(worldPos : Vector2)-> void:
	var cell = target_map.world_to_cell(worldPos)
	global_position = target_map.cell_to_world(cell) if target_map.isValidPos(cell) else worldPos
	global_position += (Vector2.ONE * target_map.CELL_SIZE) / 2.0

func place() -> bool:
	var pos := target_map.world_to_cell(global_position)
	pos -= Vector2i(mask.size() / 2, mask.size() / 2)
	var id = MultiplayerManager.client_player_id if multiplayer.is_server() else 1
	MultiplayerManager.apply_action_mask.rpc_id(id, pos, mask)
	return true
