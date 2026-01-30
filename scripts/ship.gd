class_name Ship

extends Node2D

const DIM:int = 3 
var dir:Vector2i = Vector2i(0,-1)

var positions: Array[Vector2i] = [Vector2i(4,4),Vector2i(4,5),Vector2i(4,6)]
@export var sprite : Sprite2D 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func flip() ->void:
	dir *= -1
	rotation+= PI
