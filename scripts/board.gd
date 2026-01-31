class_name Board

extends Grid

var highlightCells: Array[Vector2i]
var enemy_action: Vector2i = Vector2i(-1, -1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		var cell_pos := world_to_cell(get_global_mouse_position())
		if isValidPos(cell_pos) and MouseSelection.current_selection is Ship:
			pass

func _process(delta: float) -> void:
	queue_redraw()

func _on_action_hint(new_action_hint: Rect2i) -> void:
	action_hint = new_action_hint

func _ready() -> void:
	MultiplayerManager.action_hint.connect(_on_action_hint.bind())
	#for i in range(0, DIM):
	#	var row: Array = []
	#	for j in range(0, DIM):
	#		var cell := Sprite2D.new()
	#		cell.position = Vector2(i * CELL_SIZE, j * CELL_SIZE) + (Vector2.ONE * (CELL_SIZE / 2.0))
	#		cell.texture = preload("uid://d0dksl0vaxqvn")
	#		add_child(cell)
	#		row.push_back(cell)
	#	cells.push_back(row)

func _draw() -> void:
	super()
	var start := 0
	var end := CELL_SIZE * DIM
	var color := Color(Color.BLACK, 0.4)
	for i in range(0, DIM + 1):
		var row := i * CELL_SIZE
		draw_line(Vector2(row, start), Vector2(row, end), color, 2.0)
	for j in range(0, DIM + 1):
		var column := j * CELL_SIZE
		draw_line(Vector2(start, column), Vector2(end, column), color, 2.0)
	#for pos in highlightCells:
	#	if isValidPos(pos):
	#		draw_rect(Rect2(pos * CELL_SIZE, Vector2(CELL_SIZE, CELL_SIZE)), Color.RED)
