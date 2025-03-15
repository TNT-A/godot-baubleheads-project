extends Node2D
#fix bug: should be called hydra.gd
@export var health : int = 50

var under_attack : bool = false
var is_alive : bool = true

enum States {IDLE, ATTACK, MOVE}
var state: States = States.IDLE
func _ready():
	SignalBus.change_enemy_health.connect(change_health)

func _physics_process(delta: float) -> void:
	if is_alive == false:
		die()
	if Input.is_action_just_pressed("Testing"):
		queue_free()
	#state_transition()
	state_functions()

	
	
func state_functions():
	if state == States.ATTACK:
		if $TimerAttackCooldown.is_stopped():
			$TimerAttackCooldown.start()
			#$TimerAttackCooldown.wait_time = randf.range(1.2,2.0)
func shoot():
	#Global.player.global_position 
	pass
func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

func die():
	queue_free()
	
	
