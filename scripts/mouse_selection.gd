extends Node

var current_selection: Node2D

func select(obj: Node2D) -> void:
	if current_selection:
		current_selection.queue_free()
	current_selection = obj
	add_child(current_selection)

func deselect() -> void:
	if current_selection:
		current_selection.queue_free()

func _process(delta: float) -> void:
	if current_selection != null:
		var screen_pos := get_viewport().get_mouse_position()
		current_selection.global_position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
