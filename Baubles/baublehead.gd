extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var acceleration : float = .2
@export var deceleration : float = .05
@export var type : Resource

@onready var player : Node = Global.player

enum States {IDLE, FOLLOW, PATROL, THROWN, ATTACK, DEFEND, RETURN}
var state: States = States.IDLE

var inPlayer : bool = false

signal on_spawned(baublehead)

func _ready() -> void:
	$Sprite2D.texture = type.sprite
	$Sprite2D.scale = Vector2(2,2)
	self.position = random_spawn()
	emit_signal("on_spawned", self)
	pass

func _physics_process(delta: float) -> void:
	state_transition()
	if state == States.FOLLOW:
		move_toward_target(player.position, 250)
	if state == States.IDLE:
		resetVelocity()
	if state == States.PATROL:
		move_toward_target(get_global_mouse_position(), 350)

func state_transition():
	if state == States.IDLE and inPlayer == false:
		state = States.FOLLOW
	elif state == States.FOLLOW and inPlayer == true:
		state = States.IDLE
	elif (state == States.FOLLOW or state == States.IDLE) and Input.is_action_pressed("Player_Ability_1") == true:
		state = States.PATROL
	elif state == States.PATROL and Input.is_action_just_released("Player_Ability_1") == true:
		state = States.IDLE
	print(state)

func random_spawn():
	var rng = RandomNumberGenerator.new()
	var spawn_position : Vector2 = Vector2()
	var random_range : float = 30.0
	spawn_position.x = player.position.x + rng.randf_range(-random_range,random_range)
	spawn_position.y = player.position.y + rng.randf_range(-random_range,random_range)
	return spawn_position

func resetVelocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	if player.position > position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = false
	if player.position < position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = true

func move_toward_target(target, speed_change):
	var direction
	speed = speed_change
	direction = (target - self.position).normalized()
	velocity = velocity.lerp(direction * speed, acceleration)
	if velocity.x > 0 and abs(position.x - target.x) > 20:
		$Sprite2D.flip_h = false
	elif velocity.x < 0 and abs(position.x - target.x) > 20:
		$Sprite2D.flip_h = true
	move_and_slide()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = false
