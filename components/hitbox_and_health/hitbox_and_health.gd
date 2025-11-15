class_name HealthComponent
extends Area2D

@export var host : CharacterBody2D

@export var max_health : int = 10
@export var current_health : int = 10

@export var element_stacks : Dictionary = {
	fire = 0,
	ice = 0,
	electric = 0,
}

var self_string : String = ""
@export var isPlayer : bool = false
@export var isEnemy : bool = false
@export var isBauble : bool = false

func _ready() -> void:
	if isPlayer:
		add_to_group("player")
		self_string = "player"
	if isEnemy:
		add_to_group("enemy")
		self_string = "enemy"
	if isBauble:
		add_to_group("bauble")
		self_string = "bauble"

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	#print(area.get_groups())
	if area.is_in_group("hurts_" + self_string):
		hit(area.damage_dealt)
		if area.is_fire:
			pass
		if area.is_ice:
			pass
		if area.is_electric:
			pass

func hit(damage):
	if isPlayer:
		SignalBus.emit_signal("player_hit")
	if isEnemy:
		SignalBus.emit_signal("enemy_hit", host)
	if isBauble:
		SignalBus.emit_signal("bauble_hit", host)
	current_health -= damage
	#print("Youch!!!! ", current_health)
	if current_health <= 0:
		die()

func die():
	if isPlayer:
		SignalBus.emit_signal("player_dead")
	if isEnemy:
		SignalBus.emit_signal("enemy_dead", host)
		host.queue_free()
	if isBauble:
		SignalBus.emit_signal("bauble_dead", host)
		host.queue_free()
