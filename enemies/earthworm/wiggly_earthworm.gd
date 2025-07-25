extends CharacterBody2D

#var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

@export var health : int = 9

var starting_position : Vector2 
var target
var close_target : Vector2 
var real_target : Vector2

var has_target : bool = false
var is_alive : bool = true
var cooldown_done : bool = false
var windup_done : bool = false
var dash_done : bool = false

var dash_length : float = 1.5
var dash_windup_length : float = 0.5
var dash_cooldown : float = 4.0
var dash_dir : Vector2 
var dash_speed : int = 200

var count_attacking : int = 0

var nearby_baubles : Array = []
var attacking_baubles : Array = []

var speed : int = 75
var acceleration : float  = 0.1

enum States {FOLLOW, WINDUP, DASH}
var state: States = States.FOLLOW

func _ready() -> void:
	SignalBus.change_enemy_health.connect(change_health)
	$AnimatedSprite2D.play("default")
	if starting_position:
		global_position = starting_position

func _physics_process(delta: float) -> void:
	#print(has_target)
	state_transition()
	state_functions()
	if is_alive == false:
		die()

func state_transition():
	if state == States.FOLLOW and cooldown_done and has_target:
		state = States.WINDUP
	elif state == States.WINDUP and windup_done:
		state = States.DASH
	elif state == States.DASH and dash_done:
		state = States.FOLLOW

func state_functions():
	set_collision_layer_value(4, true)
	if state == States.FOLLOW:
		dash_done = false
		windup_done = false
		$TimerDashWindup.stop()
		$TimerDashLength.stop()
		if $TimerDashCooldown.is_stopped() and has_target:
			$TimerDashCooldown.wait_time = randf_range(dash_cooldown - 1.0, dash_cooldown + 1.0)
			$TimerDashCooldown.start()
		if player:
			$Pathfinding.active = true
			if $Pathfinding.at_target:
				$Pathfinding.active = false
				velocity = (global_position - player.global_position).normalized() * speed
			else:
				$Pathfinding.active = true
		if has_target:
			$AnimatedSprite2D.rotation = get_angle_to(player.global_position)
	if state == States.WINDUP:
		$Pathfinding.active = false
		dash_done = false
		cooldown_done = false
		$TimerDashCooldown.stop()
		$TimerDashLength.stop()
		if $TimerDashWindup.is_stopped():
			$TimerDashWindup.wait_time = dash_windup_length
			$TimerDashWindup.start()
			dash_dir = (player.global_position - global_position).normalized()
			$AnimatedSprite2D.rotation = get_angle_to(player.global_position)
	if state == States.DASH:
		set_collision_layer_value(4, false)
		$Pathfinding.active = false
		windup_done = false
		cooldown_done = false
		$TimerDashWindup.stop()
		$TimerDashCooldown.stop()
		if $TimerDashLength.is_stopped():
			$TimerDashLength.wait_time = randf_range(dash_length - 0.2, dash_length + 0.2)
			$TimerDashLength.start()
		if is_on_wall() or is_on_ceiling() or is_on_floor():
			dash_done = true
			$TimerDashLength.stop()
		velocity = (dash_dir * dash_speed)
		move_and_slide()

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

func die():
	SignalBus.enemy_dead.emit(self)
	call_deferred("queue_free")

func _on_target_detector_body_entered(body: Node2D) -> void:
	if body == player:
		if !has_target:
			$TimerDashCooldown.start()
		target = body.global_position
		has_target = true

func _on_bauble_checker_body_entered(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		nearby_baubles.append(body)

func _on_bauble_checker_body_exited(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		var index = nearby_baubles.find(body)
		nearby_baubles.remove_at(index)

func _on_timer_dash_windup_timeout() -> void:
	windup_done = true

func _on_timer_dash_cooldown_timeout() -> void:
	cooldown_done = true

func _on_timer_dash_length_timeout() -> void:
	dash_done = true
