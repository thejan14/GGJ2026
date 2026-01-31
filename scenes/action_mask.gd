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
	#MultiplayerManager.apply_action_mask()
	return true
