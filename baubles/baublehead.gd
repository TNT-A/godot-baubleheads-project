extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var attack_speed : int = 400
@export var acceleration : float = .1
@export var deceleration : float = .05
@export var type : Resource

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

enum States {IDLE, FOLLOW, PATROL, TARGETING, ATTACK, HELD, THROWN, DEFEND, RETURN}
var state: States = States.IDLE

var slot : int = 0
var sprite_height : int = 30
var throw_direction : Vector2 = Vector2(0, 0)
var attack_time_ready : bool = false
var inPlayer : bool = false #checks if bauble is around the player
var current_enemy #: Node 
var target : Vector2 
var max_range : float = 0.8
var at_range : bool = false
var damage : int = 1
var being_held : bool = false
var in_air : bool = false

func _ready() -> void:
	$TimerRange.wait_time = max_range
	for bauble in BaubleManager.bauble_inventory:
		if bauble == self:
			slot = BaubleManager.bauble_inventory.find(bauble)
	#incomplete code, should delete itself when player is not real :(
	#if !is_instance_valid(player):
		#BaubleManager.despawn_bauble(slot)
		#print("hi :D ", slot)
		#self.free()
		#print("I'm dead XD")
	speed = player.stats.speed
	if type == null:
		type = load("res://Baubles/bauble_resources/diamond_bauble.tres")
	$Sprite2D.texture = type.sprite
	$Sprite2D.scale = Vector2(2,2)
	self.position = random_location(player.position, 30.0)
	emit_signal("on_spawned", self)

func _physics_process(delta: float) -> void:
	lose_enemy()
	state_transition()
	state_functions()

#player ability 2 is right click
func state_transition():
	if state == States.IDLE and inPlayer == false:
		state = States.FOLLOW
		state_changed()
	elif state == States.FOLLOW and inPlayer:
		state = States.IDLE
		state_changed()
	elif (state == States.FOLLOW or state == States.IDLE) and Input.is_action_pressed("Player_Ability_2"):
		state = States.PATROL
		state_changed()
	elif state == States.PATROL and !Input.is_action_pressed("Player_Ability_2"):
		if detect_enemy() :
			state = States.TARGETING
		elif detect_enemy() == false:
			state = States.IDLE
		state_changed()
	elif (state == States.TARGETING or state == States.ATTACK or state == States.THROWN) and Input.is_action_just_pressed("Crackhead_Call"):
		state = States.FOLLOW
		state_changed()
	elif state == States.TARGETING and detect_enemy() == false:
		state = States.FOLLOW
		state_changed()
	elif state == States.TARGETING and attack_time_ready:
		state = States.ATTACK
		state_changed()
	elif state == States.ATTACK:
		if attack_time_ready == false:
			state = States.TARGETING
		elif current_enemy == null:
			state = States.TARGETING
			state_changed()
	if state == States.FOLLOW or state == States.IDLE:
		if Input.is_action_pressed("Player_Ability_1") and inPlayer:
			state = States.HELD
			state_changed()
	if state == States.HELD and Input.is_action_just_released("Player_Ability_1"):
		state = States.THROWN
		state_changed()
	if state == States.THROWN:
		if Input.is_action_pressed("Player_Ability_1"):
			state = States.IDLE
			state_changed()
		if !in_air:
			state = States.PATROL
			state_changed()

var attack_ready : bool = true
func state_functions():
	if state == States.FOLLOW:
		new_target(player.global_position, 50.0)
		reset_target(50)
		pathfinding(speed)
		$AnimationPlayer.play("walk")
	if state == States.IDLE:
		reset_velocity()
		$AnimationPlayer.play("idle")
	if state == States.PATROL:
		new_target(get_global_mouse_position(), 0.0)
		pathfinding(speed*1.5)
		$AnimationPlayer.play("walk")
	if state == States.TARGETING:
		if $TimerAttackCooldown.is_stopped():
			$TimerAttackCooldown.wait_time = randf_range(0.8, 1.2)
			$TimerAttackCooldown.start()
		$AnimationPlayer.play("walk")
		$Sprite2D.scale = Vector2(2,2)
		if current_enemy != null:
			new_target(current_enemy.global_position, 50.0)
		pathfinding(speed)
	if state == States.ATTACK:
		$Sprite2D.scale = Vector2(3,3)
		attack_enemy()
		$AnimationPlayer.play("attack")
	if state == States.HELD:
		$AnimationPlayer.play("sit")
		var stack_position : int = BaubleManager.held_baubles.find(self)
		carry(stack_position * sprite_height)
	if state == States.THROWN:
		$AnimationPlayer.play("thrown")
		thrown()

func state_changed():
	target_decided = false
	being_held = false
	enable_collision()
	$TimerAttackCooldown.stop()
	$TimerRange.stop()
	$Sprite2D.rotation = 0
	print("state changed ", state)

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
	#var range : Vector2 = Vector2(3,3)
	var max_enemy_distance : Vector2 = Vector2(50,50)
	var enemy_position : Vector2 = current_enemy.global_position
	var target_position : Vector2 = enemy_position + (enemy_position - global_position)
	var distance : Vector2 
	if attack_speed_timeout == false and attack_ready :
		$Sprite2D.rotation = get_angle_to(current_enemy.global_position)
		direction = (target_position - global_position).normalized()
		velocity = (attack_speed * direction)
		attack_ready = false
	distance = abs(enemy_position - global_position)
	if distance.x >= max_enemy_distance.x or distance.y >= max_enemy_distance.y:
		reset_velocity()
		SignalBus.emit_signal("change_enemy_health", current_enemy, damage)
		attack_ready = true
		attack_time_ready = false
	else:
		move_and_slide()

func carry(height):
	in_air = true
	at_range = false
	$Sprite2D.flip_h = player.sprite.flip_h
	disable_collision()
	global_position = player.hand_marker.global_position - Vector2(0, height)
	target = get_global_mouse_position()
	throw_direction = (target-global_position).normalized()
	being_held = true

func thrown():
	if $TimerRange.is_stopped():
		$TimerRange.wait_time = max_range
		print($TimerRange.wait_time)
		$TimerRange.start()
	in_air = true
	velocity = (attack_speed*throw_direction)
	move_and_slide()
	if is_on_wall():
		velocity = Vector2(0, 0)
		in_air = false
		print("I fell from hitting the wall")
	elif at_range:
		velocity = Vector2(0, 0)
		in_air = false
		print("I fell from too high range")

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

func disable_collision():
	$CollisionShape2D.disabled = true

func enable_collision():
	$CollisionShape2D.disabled = false

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
	attack_time_ready = true

func _on_timer_range_timeout() -> void:
	at_range = true
