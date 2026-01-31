class_name Map

extends Grid

const NO_CELL: Vector2i = Vector2i(-1, -1)

var hover_cell: Vector2i = NO_CELL
var markers: Dictionary[Vector2i, Node2D] = {}
var last_hit: Rect2i = Rect2i(Vector2i(-1, -1), Vector2i(0, 0))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select") and hover_cell != NO_CELL:
		if MouseSelection.current_selection is Marker:
			if markers.has(hover_cell):
				markers[hover_cell].queue_free()
			var marker: Marker = MouseSelection.current_selection.duplicate()
			marker.set_state(Marker.STATE.PLACED)
			marker.position = hover_cell * CELL_SIZE
			add_child(marker)
			markers[hover_cell] = marker
	if event.is_action_pressed("Secondary") and hover_cell != NO_CELL:
		if markers.has(hover_cell):
			markers[hover_cell].queue_free()
			markers.erase(hover_cell)

func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var target_cell = to_local(mouse_pos) / CELL_SIZE
	if target_cell.x >= 0 and target_cell.x < DIM and target_cell.y >= 0 and target_cell.y < DIM:
		hover_cell = target_cell
	else:
		hover_cell = NO_CELL
	queue_redraw()

func _draw() -> void:
	if last_hit.position.x != -1:
		draw_rect(Rect2(last_hit.position * CELL_SIZE, Vector2.ONE * 3 * CELL_SIZE), Color.WHITE, false, 5.0)
