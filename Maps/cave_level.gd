extends Node
class_name Level

@export var enemy_count: int 
@export var player_spawn: Vector2

var enemies : Array = []

func _ready() -> void:
	enemies.clear()
	player_spawn = $PlayerSpawn.global_position
	SignalBus.enemy_added.connect(add_enemy)
	SignalBus.enemy_dead.connect(remove_enemy)
	for child in self.get_children():
		if child.is_in_group("enemy"):
			enemies.append(child)
	enemy_count = enemies.size()
	print(enemy_count)
	if enemy_count <= 0:
		SignalBus.emit_signal("all_enemies_killed")

func remove_enemy(enemy):
	if enemies.has(enemy):
		enemies.erase(enemy)
	enemy_count = enemies.size()
	print(enemy_count)
	if enemy_count <= 0:
		SignalBus.emit_signal("all_enemies_killed")

func add_enemy(enemy):
	if enemy.is_in_group("enemy"):
		enemies.append(enemy)
	enemy_count = enemies.size()
