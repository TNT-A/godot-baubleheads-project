extends Node2D

@onready var player = Global.player

@export var health : int = 30

var crackshot: PackedScene = preload("res://enemies/earthworm/crackshot.tscn")
#var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

var is_alive : bool = true
var attack_time : bool = false
enum States {IDLE, ATTACK, MOVE}
var state: States = States.ATTACK
var playerCrackable : bool = false
var timer_cooldown : float = 1.6

var count_attacking : int = 0

func _ready():
	SignalBus.change_enemy_health.connect(change_health)
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	if player:
		if player.global_position < global_position and abs(global_position.x - player.global_position.x) > 20:
			$AnimatedSprite2D.flip_h = false
		if player.global_position > global_position and abs(global_position.x - player.global_position.x) > 20:
			$AnimatedSprite2D.flip_h = true
	if is_alive == false:
		die()
	state_transitions()
	state_functions()

func state_transitions():
	if playerCrackable:
		state = States.ATTACK
	elif true: #change conditional later
		state = States.MOVE

func state_functions():
	if state == States.ATTACK:
		if $TimerAttackCooldown.is_stopped():
			$TimerAttackCooldown.wait_time = randf_range(timer_cooldown - 0.1, timer_cooldown + 0.1)
			$TimerAttackCooldown.start()
		if attack_time:
			shoot()
			attack_time = false

func shoot():
	if count_attacking <= 5:
		var a = crackshot.instantiate()
		a.changeAngle(Vector2(Global.player.global_position.x - position.x, Global.player.global_position.y - position.y).normalized())
		add_child(a)
		
	#Global.player.global_position 

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

func die():
	SignalBus.enemy_dead.emit(self)
	call_deferred("queue_free")

func _on_timer_attack_cooldown_timeout():
	if playerCrackable:
		attack_time = true

func _on_area_2d_body_shape_entered(body_rid, body: Node2D, body_shape_index, local_shape_index):
	if body == Global.player:
		playerCrackable = true

func _on_area_2d_body_shape_exited(body_rid, body: Node2D, body_shape_index, local_shape_index):
	if body == Global.player:
		playerCrackable = false
		$TimerAttackCooldown.stop()
		$TimerAttackCooldown.wait_time = randf_range(1.2, 2.0)
		attack_time = false
