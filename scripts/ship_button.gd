extends TextureButton

@export var ship_scene: PackedScene
@export var targetBoard : Board

func _ready() -> void:
	pressed.connect(select_ship)

func select_ship() -> void:
	var ship := ship_scene.instantiate() as Ship
	ship.set_state(Ship.STATE.PREVIEW)
	ship.targetBoard = targetBoard
	MouseSelection.select(ship)
