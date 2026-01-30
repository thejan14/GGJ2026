extends TextureButton

@export var marker_scene: PackedScene

func _ready() -> void:
	pressed.connect(select_marker)

func select_marker() -> void:
	var marker := marker_scene.instantiate() as Marker
	marker.set_state(Marker.STATE.PREVIEW)
	MouseSelection.select(marker)
