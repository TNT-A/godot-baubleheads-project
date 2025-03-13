extends Node2D

@export var health : int = 50

var under_attack : bool = false
var is_alive : bool = true

func _ready():
	SignalBus.change_enemy_health.connect(change_health)

func _physics_process(delta: float) -> void:
	if is_alive == false:
		die()
	if Input.is_action_just_pressed("Testing"):
		queue_free()

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

func die():
	queue_free()
