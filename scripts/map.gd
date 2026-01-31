class_name Map

extends Grid

const NO_CELL: Vector2i = Vector2i(-1, -1)

var hover_cell: Vector2i = NO_CELL
var markers: Dictionary[Vector2i, Node2D] = {}

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
	var start := 0
	var end := CELL_SIZE * DIM
	for i in range(0, DIM + 1):
		var row := i * CELL_SIZE
		draw_line(Vector2(row, start), Vector2(row, end), Color.BLACK)
	for j in range(0, DIM + 1):
		var column := j * CELL_SIZE
		draw_line(Vector2(start, column), Vector2(end, column), Color.BLACK)
