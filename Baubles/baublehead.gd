extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var acceleration : float = .07
@export var deceleration : float = .05
@export var type : Resource

@onready var find_player : Node = $find_player
@onready var player : Node = Global.player

enum States {IDLE, WALKING}
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
	if state == States.WALKING:
		walk()
	if state == States.IDLE:
		resetVelocity()

func state_transition():
	if state == States.IDLE and inPlayer == false:
		state = States.WALKING
	elif state == States.WALKING and inPlayer == true:
		state = States.IDLE

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

func walk():
	var player_position 
	var target
	player_position = player.position
	target = (player_position - self.position).normalized()
	velocity = velocity.lerp(target * speed, acceleration)
	#velocity = (target*speed)
	move_and_slide()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = false
