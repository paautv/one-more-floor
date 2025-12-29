extends Node2D

@export var tile_size: int = 32

var tile: Vector2 = Vector2.ZERO

func set_tile(pos: Vector2):
	tile = pos
	position = tile * tile_size + Vector2(tile_size / 2, tile_size / 2)


func _draw():
	draw_rect(
		Rect2(
			- tile_size / 2,
			- tile_size / 2,
			tile_size,
			tile_size
		),
		Color.YELLOW
	)
