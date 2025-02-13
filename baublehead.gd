extends CharacterBody2D

@export var speed : int = 50
@export var acceleration : float = .07
@export var deceleration : float = .05

@onready var find_player : Node = $find_player
@onready var player : Node = Global.player

enum States {IDLE, WALKING}
var state: States = States.IDLE

var inPlayer : bool = false

func _ready() -> void:
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
