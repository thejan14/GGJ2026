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
	global_position = worldPos

func place() -> bool:
	var pos := target_map.world_to_cell(global_position)
	var id = MultiplayerManager.client_player_id if multiplayer.is_server() else 1
	MultiplayerManager.apply_action_mask.rpc_id(id, pos, mask)
	return true
