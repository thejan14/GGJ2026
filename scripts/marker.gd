class_name Marker

extends CursorNode

func set_state(state: STATE) -> void:
	modulate = Color(modulate, 0.5) if state == STATE.PREVIEW else Color(modulate, 1.0)
