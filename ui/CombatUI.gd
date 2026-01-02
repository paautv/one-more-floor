extends Control

var player
var monster

var player_timer := 0.0
var monster_timer := 0.0

var player_cooldown := 0.0
var monster_cooldown := 0.0

var max_lines := 4
var lines: Array[String] = []
var combat_ended := false

@onready var label: Label = $CenterContainer/Panel/VBoxContainer/CombatLabel

func start_combat(p, m):
	player = p
	monster = m

	player_timer = 0.0
	monster_timer = 0.0

	player_cooldown = player.attack_cooldown
	monster_cooldown = monster.attack_cooldown

	lines.clear()
	update_label("Combat starts!")

	# Hacemos visible la UI
	visible = true

func _process(delta):
	if player == null or monster == null:
		return

	if combat_ended:
		return

	# Aumentamos timers
	player_timer += delta
	monster_timer += delta

	# Ataque del player
	if player_timer >= player_cooldown:
		player_timer = 0.0
		perform_attack(player, monster)

	# Ataque del monster
	if monster_timer >= monster_cooldown and not monster.is_dead():
		monster_timer = 0.0
		perform_attack(monster, player)

	# Si alguno está muerto, terminamos el combate
	if player.is_dead() or monster.is_dead():
		end_combat()
		return

func perform_attack(attacker, defender):
	var attack_value = attacker.attack * attacker.level
	var defense_value = defender.defense * defender.level
	var damage = attack_value - defense_value

	if damage > 0:
		defender.take_damage(damage)
		update_label(
			"%s hits %s for %d damage (%d HP left)"
			% [attacker.name, defender.name, damage, defender.hp]
		)
	else:
		update_label(
			"%s attacks %s but deals no damage"
			% [attacker.name, defender.name]
		)

func end_combat() -> void:
	if combat_ended:
		return  # Evita que se ejecute dos veces
	combat_ended = true

	if player and monster:
		if monster.is_dead():
			update_label("Monster defeated!")
		elif player.is_dead():
			update_label("Player defeated!")

	# Detener _process para que no siga llamando end_combat
	set_process(false)

	# Esperar 1 segundo antes de ocultar la UI
	await get_tree().create_timer(0.1).timeout

	# Reanudar movimiento del player y demás entities solo si player ganó
	if player and not player.is_dead():
		for entity in get_tree().get_nodes_in_group("entities"):
			entity.resume()

	# Liberar monster
	if monster:
		monster.queue_free()

	# Limpiar referencias
	player = null
	monster = null
	
	visible = false
	queue_free()

func update_label(new_text: String):
	lines.append(new_text)

	if lines.size() > max_lines:
		lines = lines.slice(lines.size() - max_lines, lines.size())

	label.text = "\n".join(lines)
