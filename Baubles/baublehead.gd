extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var acceleration : float = .1
@export var deceleration : float = .05
@export var type : Resource

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

enum States {IDLE, FOLLOW, PATROL, THROWN, ATTACK, DEFEND, RETURN}
var state: States = States.IDLE

var inPlayer : bool = false
var target : Vector2 

signal on_spawned(baublehead)

func _ready() -> void:
	if type == null:
		type = load("res://Baubles/bauble_resources/diamond_bauble.tres")
	$Sprite2D.texture = type.sprite
	$Sprite2D.scale = Vector2(2,2)
	self.position = random_location(player.position, 30.0)
	emit_signal("on_spawned", self)
	pass

func _physics_process(delta: float) -> void:
	new_target()
	state_transition()
	state_functions()

func state_transition():
	if state == States.IDLE and inPlayer == false:
		state = States.FOLLOW
	elif state == States.FOLLOW and inPlayer == true:
		state = States.IDLE
	elif (state == States.FOLLOW or state == States.IDLE) and Input.is_action_pressed("Player_Ability_1") == true:
		state = States.PATROL
	elif state == States.PATROL and Input.is_action_just_released("Player_Ability_1") == true:
		state = States.IDLE

func state_functions():
	if state == States.FOLLOW:
		pathfinding()
		#move_toward_target(player.global_position, 250)
	if state == States.IDLE:
		resetVelocity()
	if state == States.PATROL:
		move_toward_target(get_global_mouse_position(), 350)

func random_location(location, range):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_position : Vector2 = Vector2()
		random_position.x = location.x + rng.randf_range(-range,range)
		random_position.y = location.y + rng.randf_range(-range,range)
		return random_position

func resetVelocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	#if player.position > position and abs(position.x - player.position.x) > 20:
		#$Sprite2D.flip_h = false
	#if player.position < position and abs(position.x - player.position.x) > 20:
		#$Sprite2D.flip_h = true

func move_toward_target(target, speed_change):
	var direction
	speed = speed_change
	direction = (target - self.global_position).normalized()
	velocity = velocity.lerp(direction * speed, acceleration)
	if velocity.x > 0 and abs(position.x - target.x) > 20:
		$Sprite2D.flip_h = false
	elif velocity.x < 0 and abs(position.x - target.x) > 20:
		$Sprite2D.flip_h = true
	move_and_slide()

func pathfinding():
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = velocity.lerp(dir * speed, acceleration)
	move_and_slide()

func make_path():
	if target:
		nav_agent.target_position = target
	else:
		nav_agent.target_position = player.global_position

var target_timeout = false
func new_target():
	if target_timeout == false:
		target = random_location(player.global_position, 100.0)
		target_timeout = true
		await get_tree().create_timer(.30).timeout
		target_timeout = false

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = false

func _on_timer_timeout() -> void:
	make_path()
