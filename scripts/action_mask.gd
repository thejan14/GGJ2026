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
	if target_map.isValidPos(cell):
		global_position = target_map.cell_to_world(cell)
		var dim := mask[0].size()
		var target = cell - Vector2i(mask.size() / 2, mask.size() / 2)
		MultiplayerManager.last_action_hint = Rect2i(cell, Vector2i(dim, dim))
	else:
		global_position = worldPos
		MultiplayerManager.last_action_hint = Rect2i(Vector2i(-1, -1), Vector2i())
	MultiplayerManager.last_action_updated = true
	global_position += (Vector2.ONE * target_map.CELL_SIZE) / 2.0

func place() -> bool:
	var pos := target_map.world_to_cell(global_position)
	pos -= Vector2i(mask.size() / 2, mask.size() / 2)
	var dim := mask[0].size()
	target_map.action_hint = Rect2i(pos, Vector2i(dim, dim))
	var id = MultiplayerManager.get_enemy_id()
	MultiplayerManager.apply_action_mask.rpc_id(id, pos, mask)
	return true
