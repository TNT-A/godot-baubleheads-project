extends Node2D
#fix bug: should be called hydra.gd
@export var health : int = 50
var crackshot: PackedScene = preload("res://Enemies/Earthworm/crackshot.tscn")
var under_attack : bool = false
var is_alive : bool = true
var attack_time : bool = false
enum States {IDLE, ATTACK, MOVE}
var state: States = States.ATTACK


func _ready():
	SignalBus.change_enemy_health.connect(change_health)
	

func _physics_process(delta: float) -> void:
	if is_alive == false:
		die()
	if Input.is_action_just_pressed("Testing"):
		queue_free()
	
	state_functions()

func state_functions():
	if state == States.ATTACK:
		
		if $TimerAttackCooldown.is_stopped():
			
			$TimerAttackCooldown.wait_time = randf_range(1.2,2.0)
			$TimerAttackCooldown.start()
	if attack_time:
		shoot()
		attack_time = false
func shoot():
	
	add_child(crackshot.instantiate())
	
	
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



	


func _on_timer_attack_cooldown_timeout():
	attack_time = true
