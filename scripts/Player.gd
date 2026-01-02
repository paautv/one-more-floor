extends Node2D

@export var tile_size: int = 32

@export var level := 1
@export var max_hp := 2 * level
@export var attack := 2 * level
@export var defense := 1 * level
@export var speed: float = 50
@export var attack_cooldown := 1.0

var hp := max_hp
var alive := true
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

		# DETENER SI LLEGA A LA CELDA VERDE
		if current_tile == get_parent().exit_cell:
			stop()
			# Detener también a los monstruos
			for e in get_tree().get_nodes_in_group("entities"):
				e.stop()
			return

		target_tile = get_next_tile()
		if target_tile == Vector2(-1,-1):
			stop()
		
		check_monster_encounter()

func check_monster_encounter():
	var maze = get_parent()
	for monster in maze.get_monsters():
		if monster.current_tile == current_tile:
			maze.start_combat(self, monster)
			return

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

func resume():
	moving = true

func get_max_hp() -> int:
	return max_hp

func get_attack() -> int:
	return attack

func get_defense() -> int:
	return defense

func take_damage(amount: int):
	hp = max(hp - amount, 0)
	if hp <= 0:
		alive = false

func is_dead() -> bool:
	return hp <= 0

func die():
	stop()
	print("PLAYER DEAD")

func _draw():
	draw_circle(Vector2.ZERO, tile_size/2 * 0.8, Color.BLUE)
