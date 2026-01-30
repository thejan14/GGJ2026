extends TextureButton

@export var ship_scene: PackedScene

func _ready() -> void:
	pressed.connect(select_ship)

func select_ship() -> void:
	var ship := ship_scene.instantiate() as Ship
	ship.set_state(Ship.STATE.PREVIEW)
	MouseSelection.select(ship)
