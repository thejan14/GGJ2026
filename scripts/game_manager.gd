extends Node

@export var cam: Camera2D
@export var board: Board

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Select"):
		print(board.world_to_cell(board.get_global_mouse_position()))
	if event.is_action_pressed("Cancel"):
		get_tree().quit()

func _ready() -> void:
	cam.make_current()
