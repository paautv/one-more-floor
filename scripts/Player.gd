extends Node2D

@export var tile_size: int = 32
@export var speed: float = 100

var visited = {}        # Diccionario para marcar tiles visitados
var current_tile = Vector2(1,1)  # Empezamos en la entrada
var target_tile = Vector2.ZERO
var moving = false

# Orden predefinido: arriba, derecha, abajo, izquierda
var directions = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]

func _ready():
	position = current_tile * tile_size + Vector2(tile_size/2, tile_size/2)
	target_tile = current_tile
	moving = true
	update()  # dibuja círculo azul

func _process(delta):
	if not moving:
		return

	# Mover hacia target_tile
	var target_pos = target_tile * tile_size + Vector2(tile_size/2, tile_size/2)
	var dir = (target_pos - position).normalized()
	position += dir * speed * delta

	# Llegamos al tile
	if position.distance_to(target_pos) < 2:
		position = target_pos
		current_tile = target_tile
		visited[str(current_tile)] = true
		# Elegir siguiente tile según orden predefinido y no visitado
		target_tile = get_next_tile()
		if target_tile == Vector2(-1,-1):
			moving = false  # no hay tile válido

func get_next_tile() -> Vector2:
	var maze = get_parent()
	for dir in directions:
		var next_tile = current_tile + dir
		# Comprobar límites
		if next_tile.x < 0 or next_tile.y < 0 or next_tile.y >= maze.height or next_tile.x >= maze.width:
			continue
		# Comprobar si es camino y no visitado
		if maze.map[next_tile.y][next_tile.x] == 0 and not visited.has(str(next_tile)):
			return next_tile
	return Vector2(-1,-1)  # no hay tile válido

func _draw():
	draw_circle(Vector2.ZERO, tile_size/2*0.8, Color.BLUE)

func update():
	_draw()
