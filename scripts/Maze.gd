extends Node2D

@export var level: int = 7
@export var base_width: int = 10
@export var base_height: int = 10
@export var tile_size: int = 32

var map: Array = []
var width: int = 0
var height: int = 0

var chests: Array = []
var monsters: Array = []

func _ready():
	randomize()
	generate_maze(level)
	place_specials(level)

	var PlayerScene = preload("res://scenes/Player.tscn")
	var player = PlayerScene.instantiate()
	add_child(player)

	player.current_tile = Vector2(1, 1)
	player.position = player.current_tile * tile_size + Vector2(tile_size / 2, tile_size / 2)
	player.moving = true

	queue_redraw()

# --------------------------------------------------
# LABERINTO
# --------------------------------------------------
func generate_maze(level: int):
	width = base_width + level
	height = base_height + level

	if width % 2 == 0:
		width += 1
	if height % 2 == 0:
		height += 1

	map.clear()
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(1)
		map.append(row)

	carve_maze_iterative(1, 1)

	map[1][1] = 0
	map[height - 2][width - 2] = 0

func carve_maze_iterative(start_x: int, start_y: int):
	var stack: Array = []
	stack.append(Vector2(start_x, start_y))
	map[start_y][start_x] = 0

	var directions = [
		Vector2(0, -2),
		Vector2(2, 0),
		Vector2(0, 2),
		Vector2(-2, 0)
	]

	while stack.size() > 0:
		var current = stack.back()
		var cx = int(current.x)
		var cy = int(current.y)

		var dirs = directions.duplicate()
		dirs.shuffle()

		var carved = false
		for dir in dirs:
			var nx = cx + int(dir.x)
			var ny = cy + int(dir.y)

			if nx > 0 and ny > 0 and nx < width - 1 and ny < height - 1:
				if map[ny][nx] == 1:
					map[cy + int(dir.y / 2)][cx + int(dir.x / 2)] = 0
					map[ny][nx] = 0
					stack.append(Vector2(nx, ny))
					carved = true
					break

		if not carved:
			stack.pop_back()

# --------------------------------------------------
# COFRES Y MONSTRUOS (ALEATORIOS)
# --------------------------------------------------
func place_specials(level: int):
	chests.clear()
	monsters.clear()

	var path_cells: Array = []

	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			if map[y][x] == 0 and pos != Vector2(1, 1) and pos != Vector2(width - 2, height - 2):
				path_cells.append(pos)

	path_cells.shuffle()

	if path_cells.size() == 0:
		return

	var max_available = path_cells.size()

	var chest_count = randi_range(1, min(level, max_available))
	var monster_count = randi_range(1, min(level, max_available - chest_count))

	for i in range(chest_count):
		chests.append(path_cells[i])

	for i in range(chest_count, chest_count + monster_count):
		monsters.append(path_cells[i])

# --------------------------------------------------
# DIBUJO
# --------------------------------------------------
func _draw():
	if map.is_empty():
		return

	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			var color = Color.BLACK

			if map[y][x] == 0:
				color = Color.GRAY

			if pos == Vector2(1, 1):
				color = Color.WHITE
			elif pos == Vector2(width - 2, height - 2):
				color = Color.GREEN
			elif pos in chests:
				color = Color.YELLOW
			elif pos in monsters:
				color = Color.RED

			draw_rect(
				Rect2(
					x * tile_size,
					y * tile_size,
					tile_size,
					tile_size
				),
				color
			)
