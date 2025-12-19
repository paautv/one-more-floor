extends Node2D

@export var tile_size: int = 32
@export var speed: float = 100

var visited = {}
var current_tile = Vector2.ZERO
var target_tile = Vector2.ZERO
var moving = false

var history = []  # historial para retroceder correctamente

# Orden predefinido: arriba, derecha, abajo, izquierda
var directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]

func _ready():
	if current_tile == Vector2.ZERO:
		current_tile = get_parent().player_start
	target_tile = current_tile
	position = current_tile * tile_size + Vector2(tile_size/2, tile_size/2)
	moving = true
	visited[str(current_tile)] = true
	history.append(current_tile)

func _process(delta):
	if not moving:
		return

	var target_pos = target_tile * tile_size + Vector2(tile_size/2, tile_size/2)
	var dir = (target_pos - position).normalized()
	position += dir * speed * delta

	if position.distance_to(target_pos) < 2:
		position = target_pos
		current_tile = target_tile
		if not visited.has(str(current_tile)):
			visited[str(current_tile)] = true
			history.append(current_tile)

		# DETENER SI LLEGA A LA CELDA VERDE
		if current_tile == get_parent().exit_cell:
			moving = false
			# Detener también a los monstruos
			for m in get_parent().get_children():
				if m != self:
					m.moving = false
			return

		target_tile = get_next_tile()
		if target_tile == Vector2(-1,-1):
			moving = false

func get_next_tile() -> Vector2:
	var maze = get_parent()

	# Primero vecinos no visitados
	for dir in directions:
		var next_tile = current_tile + dir
		if next_tile.x < 0 or next_tile.y < 0 or next_tile.x >= maze.width or next_tile.y >= maze.height:
			continue
		if maze.map[int(next_tile.y)][int(next_tile.x)] == 0 and not visited.has(str(next_tile)):
			return next_tile

	# Si no hay no visitados, retrocedemos por historial
	while history.size() > 1:
		history.pop_back()
		var prev_tile = history[history.size()-1]
		if maze.map[int(prev_tile.y)][int(prev_tile.x)] == 0:
			return prev_tile

	return Vector2(-1,-1)

func stop():
	moving = false

func _draw():
	draw_circle(Vector2.ZERO, tile_size/2 * 0.8, Color.BLUE)
