class_name Marker

extends Sprite2D

enum STATE { PREVIEW, PLACED }

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)
