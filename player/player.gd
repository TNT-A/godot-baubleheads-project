extends CharacterBody2D

@onready var hhealth: HealthComponent = $HitboxAndHealth

@export var acceleration : float = .25
@export var deceleration : float = .25

@export var stats : Dictionary = {
	speed = 20,
}

@onready var hand_marker = $Marker2D
@onready var sprite = $AnimatedSprite2D

enum States {IDLE, WALKING, SPRINTING, HOLDING}
var state: States = States.IDLE
var canHit = true
var accept_input : bool = true
var sprinting : bool = false

func _ready() -> void:
	SignalBus.player_hit.connect(change_health)
	z_index = 100
	Global.register_player(self)
	set_stats()
	SignalBus.emit_signal("set_health_bar", $HitboxAndHealth.max_health, $HitboxAndHealth.current_health)

func set_stats():
	Global.register_player(self)
	for stat in stats:
		stats[stat] = Global.player_stats[stat]

func change_health():
	SignalBus.emit_signal("set_health_bar", $HitboxAndHealth.max_health, $HitboxAndHealth.current_health)
	flash(6)

func _physics_process(delta: float) -> void:
	state_transition()
	set_sprint()
	state_functions()
	#print(state)

func state_functions():
	if state == States.IDLE:
		#stats.speed = 200
		reset_velocity()
		$AnimatedSprite2D.play("idle")
	if state == States.WALKING:
		#stats.speed = 200
		walk(stats.speed)
		$AnimatedSprite2D.play("walk")
	if state == States.SPRINTING:
		#stats.speed = 250
		walk(stats.speed)
		$AnimatedSprite2D.play("run")
	if state == States.HOLDING:
		#stats.speed = 200
		walk(stats.speed)
		$AnimatedSprite2D.play("run_and_hold")

func state_transition():
	if state == States.IDLE and check_for_input() == true:
		state = States.WALKING
	elif (state == States.WALKING or state == States.SPRINTING) and check_for_input() == false:
		state = States.IDLE
	#elif state == States.WALKING and sprinting:
		#state = States.SPRINTING
	#elif state == States.SPRINTING and !sprinting:
		#state = States.WALKING
	#elif (state == States.IDLE or state == States.WALKING or state == States.SPRINTING):
		#state = States.HOLDING
	#elif state == States.HOLDING:
		#state = States.IDLE

func check_for_input():
	var isButtonPressed : bool = false
	if accept_input and (Input.is_action_pressed("Move_Left") or Input.is_action_pressed("Move_Right") or Input.is_action_pressed("Move_Down") or Input.is_action_pressed("Move_Up")):
		isButtonPressed = true
	else:
		isButtonPressed = false
	return isButtonPressed

func get_direction():
	var input : Vector2 = Vector2()
	if accept_input and Input.is_action_pressed("Move_Up"):
		input.y -=1
	if accept_input and Input.is_action_pressed("Move_Down"):
		input.y +=1
	if accept_input and Input.is_action_pressed("Move_Left"):
		input.x -=1
	if accept_input and Input.is_action_pressed("Move_Right"):
		input.x +=1
	return input

func set_sprint():
	if accept_input and Input.is_action_just_pressed("Sprint"):
		if sprinting == true:
			sprinting = false
		elif sprinting == false:
			sprinting = true

func reset_velocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	#velocity = Vector2(0,0)

func walk(new_speed):
	var direction : Vector2 = get_direction()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * new_speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO,deceleration)
	if velocity.x > 0:
		sprite.flip_h = false
		hand_marker.position = Vector2(5, -12)
	elif velocity.x < 0:
		sprite.flip_h = true
		hand_marker.position = Vector2(-5, -12)
	move_and_slide()
	#print(velocity)

func flash(count):
	$HitboxAndHealth.invincible = true
	for n in range(count):
		visible = false
		await get_tree().create_timer(0.07).timeout
		visible = true
		await get_tree().create_timer(0.07).timeout
	$HitboxAndHealth.invincible = false
	
