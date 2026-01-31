class_name ResultInfo

extends Control

@export var result_sprites: Array[Texture2D]
@export var info_grid: GridContainer

func set_result(result: Array[PackedInt32Array]) -> void:
	for child in get_children():
		child.queue_free()
	for row in result:
		for info in row:
			var block = TextureRect.new()
			block.texture = result_sprites[info]
			add_child(block)
