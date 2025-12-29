extends Node2D

@export var tile_size: int = 32
@export var speed: float = 50
@export var attack_cooldown := 1.5

var current_tile = Vector2.ZERO
var target_tile = Vector2.ZERO
var moving = false
var visited = {}
var history = []  # Historial para retroceder

# Orden de movimiento: arriba, derecha, abajo, izquierda
var directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]

func _ready():
	add_to_group("monsters")
	add_to_group("entities")
	
func set_start_tile(pos: Vector2):
	current_tile = pos
	target_tile = pos
	position = pos * tile_size + Vector2(tile_size/2, tile_size/2)
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
		target_tile = get_next_tile()
		if target_tile == Vector2(-1,-1):
			moving = false

func get_next_tile() -> Vector2:
	var maze = get_parent()

	# Primero intentamos ir a celdas no visitadas en orden predefinido
	for dir in directions:
		var next_tile = current_tile + dir
		if next_tile.x < 0 or next_tile.y < 0 or next_tile.x >= maze.width or next_tile.y >= maze.height:
			continue
		if maze.map[int(next_tile.y)][int(next_tile.x)] == 0 and not visited.has(str(next_tile)):
			return next_tile

	# Si no hay no visitadas, retrocedemos por el historial
	while history.size() > 1:
		history.pop_back()  # Sacamos la celda actual
		var prev_tile = history[history.size()-1]
		if maze.map[int(prev_tile.y)][int(prev_tile.x)] == 0:
			return prev_tile

	# No hay tile válido
	return Vector2(-1,-1)

func stop():
	moving = false

func _draw():
	draw_circle(Vector2.ZERO, tile_size/2*0.8, Color.RED)
