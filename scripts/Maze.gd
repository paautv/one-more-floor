extends Node2D

@export var level: int = 1
@export var base_width: int = 10
@export var base_height: int = 10
@export var tile_size: int = 32

var map: Array = []
var width: int = 0
var height: int = 0

var chests: Array = []
var monsters: Array = []

var player_start: Vector2 = Vector2.ZERO
var exit_cell: Vector2 = Vector2.ZERO

func _ready():
	randomize()
	generate_maze(level)
	place_specials(level)

	# -------------------------
	# Instanciar salida
	# -------------------------
	var ExitScene = preload("res://scenes/Exit.tscn")
	var exit = ExitScene.instantiate()
	add_child(exit)
	exit.set_tile(exit_cell)

	# -------------------------
	# Instanciar cofres (ENTIDADES)
	# -------------------------
	var ChestScene = preload("res://scenes/Chest.tscn")
	for c_pos in chests:
		var chest = ChestScene.instantiate()
		add_child(chest)
		chest.set_tile(c_pos)

	# -------------------------
	# Instanciar monstruos
	# -------------------------
	var MonsterScene = preload("res://scenes/Monster.tscn")
	for m_pos in monsters:
		var monster = MonsterScene.instantiate()
		add_child(monster)
		monster.set_start_tile(m_pos)

	# -------------------------
	# Instanciar jugador
	# -------------------------
	var PlayerScene = preload("res://scenes/Player.tscn")
	var player = PlayerScene.instantiate()
	add_child(player)
	player.set_start_tile(player_start)

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

	# -------------------------
	# Entrada y salida aleatorias
	# -------------------------
	var path_cells: Array = []
	for y in range(height):
		for x in range(width):
			if map[y][x] == 0:
				path_cells.append(Vector2(x, y))

	path_cells.shuffle()

	player_start = path_cells[0]
	exit_cell = path_cells[1]

# DFS ITERATIVO
func carve_maze_iterative(start_x: int, start_y: int):
	var stack: Array = [Vector2(start_x, start_y)]
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
# COFRES Y MONSTRUOS
# --------------------------------------------------
func place_specials(level: int):
	chests.clear()
	monsters.clear()

	var path_cells: Array = []
	for y in range(height):
		for x in range(width):
			var pos = Vector2(x, y)
			if map[y][x] == 0 and pos != player_start and pos != exit_cell:
				path_cells.append(pos)

	path_cells.shuffle()
	if path_cells.is_empty():
		return

	var chest_count = randi_range(1, min(level, path_cells.size()))
	for i in range(chest_count):
		chests.append(path_cells[i])

	var remaining_cells = path_cells.slice(chest_count)
	if remaining_cells.is_empty():
		return

	var monster_count = randi_range(1, min(level, remaining_cells.size()))
	for i in range(monster_count):
		monsters.append(remaining_cells[i])

func get_monsters() -> Array:
	var result = []
	for c in get_children():
		if c.is_in_group("monsters"):
			result.append(c)
	return result

func start_combat(player, monster):
	# Parar todo
	get_tree().call_group("entities", "stop")

	# Mostrar UI de combate
	var CombatScene = preload("res://ui/CombatUI.tscn")
	var combat_ui = CombatScene.instantiate()
	add_child(combat_ui)

	combat_ui.start_combat(player, monster)

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

			draw_rect(
				Rect2(x * tile_size, y * tile_size, tile_size, tile_size),
				color
			)
