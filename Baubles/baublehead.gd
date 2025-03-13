extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var attack_speed : int = 400
@export var acceleration : float = .1
@export var deceleration : float = .05
@export var type : Resource

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

enum States {IDLE, FOLLOW, PATROL, TARGETING, ATTACK, DEFEND, RETURN, THROWN}
var state: States = States.IDLE

var attack_time : bool = false
var inPlayer : bool = false
var current_enemy #: Node 
var target : Vector2 
var damage : int = 1

func _ready() -> void:
	speed = player.speed
	if type == null:
		type = load("res://Baubles/bauble_resources/diamond_bauble.tres")
	$Sprite2D.texture = type.sprite
	$Sprite2D.scale = Vector2(2,2)
	self.position = random_location(player.position, 30.0)
	emit_signal("on_spawned", self)
	pass

func _physics_process(delta: float) -> void:
	lose_enemy()
	state_transition()
	state_functions()

func state_transition():
	if state == States.IDLE and inPlayer == false:
		state = States.FOLLOW
		state_changed()
	elif state == States.FOLLOW and inPlayer == true:
		state = States.IDLE
		state_changed()
	elif (state == States.FOLLOW or state == States.IDLE) and Input.is_action_pressed("Player_Ability_2") == true:
		state = States.PATROL
		state_changed()
	elif state == States.PATROL and Input.is_action_just_released("Player_Ability_2") == true:
		if detect_enemy() == true:
			state = States.TARGETING
		elif detect_enemy() == false:
			state = States.IDLE
		state_changed()
	elif state == States.TARGETING and detect_enemy() == false:
		state = States.FOLLOW
		state_changed()
	elif state == States.TARGETING and attack_time == true:
		state = States.ATTACK
		state_changed()
	elif state == States.ATTACK:
		if attack_time == false:
			state = States.TARGETING
		elif current_enemy == null:
			state = States.TARGETING
		state_changed()

var attack_ready : bool = true
func state_functions():
	if state == States.FOLLOW:
		new_target(player.global_position, 50.0)
		reset_target(50)
		pathfinding(speed)
	if state == States.IDLE:
		reset_velocity()
	if state == States.PATROL:
		new_target(get_global_mouse_position(), 0.0)
		pathfinding(speed*1.5)
	if state == States.TARGETING:
		if $TimerAttackCooldown.is_stopped():
			$TimerAttackCooldown.start()
		$Sprite2D.scale = Vector2(2,2)
		if current_enemy != null:
			new_target(current_enemy.global_position, 50.0)
		pathfinding(speed)
	if state == States.ATTACK:
		$Sprite2D.scale = Vector2(3,3)
		attack_enemy()

func state_changed():
	target_decided = false
	$TimerAttackCooldown.stop()
	$Sprite2D.rotation = 0

func random_location(location, range):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_position : Vector2 = Vector2()
		random_position.x = location.x + rng.randf_range(-range,range)
		random_position.y = location.y + rng.randf_range(-range,range)
		return random_position

func random_pivot(range):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_pivot : Vector2 = Vector2()
		random_pivot.x = rng.randf_range(-range,range)
		random_pivot.y = rng.randf_range(-range,range)
		return random_pivot

func reset_velocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	if player.position > position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = false
	if player.position < position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = true

func detect_enemy():
	var inEnemy : bool = false
	if current_enemy != null:
		inEnemy = true
	else:
		inEnemy = false
	return inEnemy

var attack_speed_timeout : bool = false
func attack_enemy():
	var direction : Vector2 
	var range : Vector2 = Vector2(3,3)
	var max_enemy_distance : Vector2 = Vector2(50,50)
	var enemy_position : Vector2 = current_enemy.global_position
	var target_position : Vector2 = enemy_position + (enemy_position - global_position)
	var distance : Vector2 
	if attack_speed_timeout == false and attack_ready == true:
		$Sprite2D.rotation = get_angle_to(current_enemy.global_position)
		direction = (target_position - global_position).normalized()
		velocity = (attack_speed * direction)
		attack_ready = false
		#print("Iran")
	distance = abs(enemy_position - global_position)
	if distance.x >= max_enemy_distance.x or distance.y >= max_enemy_distance.y:
		reset_velocity()
		SignalBus.emit_signal("change_enemy_health", current_enemy, damage)
		attack_ready = true
		attack_time = false
		#print("I'll end it all now!")
	else:
		move_and_slide()
		#print(distance, " ", state, " ", velocity, " ", attack_ready)

func pathfinding(speed_change):
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = velocity.lerp(dir * speed_change, acceleration)
	if player.position > position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = false
	if player.position < position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = true
	move_and_slide()

func make_path():
	if target:
		nav_agent.target_position = target
	else:
		nav_agent.target_position = player.global_position

var target_pivot : Vector2 
var target_decided : bool = false
func new_target(target_position, range):
	if target_decided == false:
		target_pivot = Vector2(0,0)
		target_pivot = random_pivot(range)
		target_decided = true
	target = target_position + target_pivot

var target_timeout = false
func reset_target(range):
	if target_timeout == false:
		target_pivot = random_pivot(range)
		target_timeout = true
		await get_tree().create_timer(2.0).timeout
		target_timeout = false

func lose_enemy():
	if is_instance_valid(current_enemy):
		pass
	else:
		current_enemy = null

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = true
	if body.is_in_group("enemy") and state == States.PATROL:
		current_enemy = body

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = false

func _on_timer_timeout() -> void:
	make_path()

func _on_timer_attack_timeout() -> void:
	attack_time = true
