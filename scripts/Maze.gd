extends Node2D

@export var level: int = 5
@export var base_width: int = 10
@export var base_height: int = 10
@export var tile_size: int = 32

var map = []
var width = 0
var height = 0

# Listas de posiciones especiales
var chests = []
var monsters = []

func _ready():
	generate_maze(level)
	place_specials(level)
	# _draw() se llamará automáticamente

# Genera laberinto totalmente conectado
func generate_maze(level: int):
	width = base_width + level
	height = base_height + level
	
	if level % 2 == 0:
		width += 1
		height += 1

	# Inicializa mapa lleno de paredes
	map.clear()
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(1)
		map.append(row)

	# DFS recursivo para generar caminos
	carve_path(1,1)

	# Entrada y salida
	map[1][1] = 0
	map[height-2][width-2] = 0

func carve_path(x: int, y: int):
	map[y][x] = 0
	var dirs = [Vector2(0,-2), Vector2(2,0), Vector2(0,2), Vector2(-2,0)]
	dirs.shuffle()
	
	for dir in dirs:
		var nx = x + int(dir.x)
		var ny = y + int(dir.y)
		if nx > 0 and ny > 0 and nx < width - 1 and ny < height - 1:
			if map[ny][nx] == 1:
				# Carve wall in between
				map[y + int(dir.y/2)][x + int(dir.x/2)] = 0
				carve_path(nx, ny)

# Coloca cofres y monstruos
func place_specials(level: int):
	chests.clear()
	monsters.clear()
	var path_cells = []
	
	# Recolecta todas las celdas de camino
	for y in range(height):
		for x in range(width):
			if map[y][x] == 0 and !((x == 1 and y == 1) or (x == width-2 and y == height-2)):
				path_cells.append(Vector2(x,y))
	
	path_cells.shuffle()
	
	# Cofres
	for i in range(min(level, path_cells.size())):
		chests.append(path_cells[i])
	
	# Monstruos
	for i in range(level, min(level*2, path_cells.size())):
		monsters.append(path_cells[i])

func _draw():
	if map.is_empty():
		return
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x,y)
			var color = Color.BLACK
			if map[y][x] == 0:
				color = Color.GRAY
			if pos == Vector2(1,1):
				color = Color.WHITE  # Entrada
			elif pos == Vector2(width-2,height-2):
				color = Color.GREEN  # Salida
			elif pos in chests:
				color = Color.YELLOW  # Cofres
			elif pos in monsters:
				color = Color.RED  # Monstruos
			
			draw_rect(Rect2(x * tile_size, y * tile_size, tile_size, tile_size), color)
