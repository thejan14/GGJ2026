class_name ActionButton

extends TextureButton

@export var action_scene: PackedScene
@export var targetBoard : Map

func _ready() -> void:
	pressed.connect(select_marker)

func select_marker() -> void:
	var action := action_scene.instantiate() as ActionMask
	action.target_map = targetBoard
	MouseSelection.select(action)
