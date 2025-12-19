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

var player_start: Vector2 = Vector2.ZERO  # Celda inicial aleatoria

func _ready():
	randomize()
	generate_maze(level)
	place_specials(level)

	# -------------------------
	# Instanciar jugador
	# -------------------------
	var PlayerScene = preload("res://scenes/Player.tscn")
	var player = PlayerScene.instantiate()
	add_child(player)

	player.current_tile = player_start
	player.position = player_start * tile_size + Vector2(tile_size/2, tile_size/2)
	player.moving = true

	# -------------------------
	# Instanciar monstruos
	# -------------------------
	var MonsterScene = preload("res://scenes/Monster.tscn")
	for m_pos in monsters:
		var monster = MonsterScene.instantiate()
		add_child(monster)

		monster.set_start_tile(m_pos)
		monster.position = m_pos * tile_size + Vector2(tile_size/2, tile_size/2)
		monster.moving = true

	# Dibujar
	call_deferred("update")  # dibuja todo una vez añadido a la escena

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

	# -------------------------
	# Entrada aleatoria
	# -------------------------
	var path_cells: Array = []
	for y in range(height):
		for x in range(width):
			if map[y][x] == 0:
				path_cells.append(Vector2(x, y))

	path_cells.shuffle()
	player_start = path_cells[0]
	map[int(player_start.y)][int(player_start.x)] = 0

	# Salida aleatoria
	var exit_cell = path_cells[1]
	map[int(exit_cell.y)][int(exit_cell.x)] = 0

# DFS ITERATIVO para laberinto
func carve_maze_iterative(start_x: int, start_y: int):
	var stack: Array = [Vector2(start_x, start_y)]
	map[start_y][start_x] = 0

	var directions = [Vector2(0, -2), Vector2(2, 0), Vector2(0, 2), Vector2(-2, 0)]

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
					map[cy + int(dir.y/2)][cx + int(dir.x/2)] = 0
					map[ny][nx] = 0
					stack.append(Vector2(nx, ny))
					carved = true
					break

		if not carved:
			stack.pop_back()

# --------------------------------------------------
# COFRES Y MONSTRUOS (aleatorios)
# --------------------------------------------------
func place_specials(level: int):
	chests.clear()
	monsters.clear()

	var path_cells: Array = []
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			if map[y][x] == 0 and pos != player_start:
				path_cells.append(pos)

	path_cells.shuffle()
	if path_cells.size() == 0:
		return

	# Cofres aleatorios
	var chest_count = randi_range(1, min(level, path_cells.size()))
	for i in range(chest_count):
		chests.append(path_cells[i])

	# Monstruos en celdas restantes
	var remaining_cells = path_cells.slice(chest_count, path_cells.size())
	if remaining_cells.size() == 0:
		return

	var monster_count = randi_range(1, min(level, remaining_cells.size()))
	for i in range(monster_count):
		monsters.append(remaining_cells[i])

# --------------------------------------------------
# DIBUJO
# --------------------------------------------------
func _draw():
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			var color = Color.BLACK if map[y][x] == 1 else Color.GRAY

			if pos == player_start:
				color = Color.WHITE
			elif pos in chests:
				color = Color.YELLOW
			elif pos in monsters:
				color = Color.RED

			draw_rect(Rect2(x * tile_size, y * tile_size, tile_size, tile_size), color)
