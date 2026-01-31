extends TextureButton

@export var marker_scene: PackedScene
@export var targetBoard : Map

func _ready() -> void:
	pressed.connect(select_marker)

func select_marker() -> void:
	var marker := marker_scene.instantiate() as Marker
	marker.set_state(Marker.STATE.PREVIEW)
	marker.targetBoard = targetBoard
	MouseSelection.select(marker)
