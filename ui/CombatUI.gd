extends Control

var player
var monster
var player_cooldown
var monster_cooldown

# Contadores independientes
var player_timer := 0.0
var monster_timer := 0.0

@onready var label: Label = $CenterContainer/Panel/VBoxContainer/CombatLabel

func start_combat(p, m):
	player = p
	monster = m
	player_timer = 0.0
	monster_timer = 0.0
	player_cooldown = player.attack_cooldown
	monster_cooldown = monster.attack_cooldown

	label.text = "Combat starts!"

func _process(delta):
	if player == null or monster == null:
		return

	# Actualizamos temporizadores
	player_timer += delta
	monster_timer += delta

	# Ataque del player
	if player_timer >= player_cooldown:
		player_attack()
		player_timer = 0.0

	# Ataque del monster
	if monster_timer >= monster_cooldown:
		monster_attack()
		monster_timer = 0.0

func player_attack():
	label.text = "Player attacks the monster"
	# Aquí iría daño, animación, etc.

func monster_attack():
	label.text = "Monster attacks the player"
	# Aquí iría daño, animación, etc.
