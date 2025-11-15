extends CharacterBody2D

@export var acceleration : float = .1
@export var deceleration : float = .1

@export var stats : Dictionary = {
	max_health = 5,
	health = 5,
	speed = 250,
}

@onready var hand_marker = $Marker2D
@onready var sprite = $AnimatedSprite2D

enum States {IDLE, WALKING, SPRINTING, HOLDING}
var state: States = States.IDLE
var canHit = true
var accept_input : bool = true
var sprinting : bool = false

func _ready() -> void:
	z_index = 100
	Global.register_player(self)
	set_stats()
	SignalBus.emit_signal("set_health_bar", stats.max_health, stats.health)

func set_stats():
	Global.register_player(self)
	for stat in stats:
		stats[stat] = Global.player_stats[stat]

func change_health(change):
	stats.health -= change
	if stats.health <= 0:
		stats.health = 0
		die()
	SignalBus.emit_signal("set_health_bar", stats.max_health, stats.health)

func _physics_process(delta: float) -> void:
	state_transition()
	set_sprint()
	state_functions()
	#print(state)

func state_functions():
	if state == States.IDLE:
		stats.speed = 250
		reset_velocity()
		$AnimatedSprite2D.play("idle")
	if state == States.WALKING:
		stats.speed = 250
		walk(stats.speed)
		$AnimatedSprite2D.play("walk")
	if state == States.SPRINTING:
		stats.speed = 350
		walk(stats.speed)
		$AnimatedSprite2D.play("run")
	if state == States.HOLDING:
		stats.speed = 250
		walk(stats.speed)
		$AnimatedSprite2D.play("run_and_hold")

func state_transition():
	if state == States.IDLE and check_for_input() == true:
		state = States.WALKING
	elif (state == States.WALKING or state == States.SPRINTING) and check_for_input() == false:
		state = States.IDLE
	elif state == States.WALKING and sprinting:
		state = States.SPRINTING
	elif state == States.SPRINTING and !sprinting:
		state = States.WALKING
	elif (state == States.IDLE or state == States.WALKING or state == States.SPRINTING) and BaubleManager.held_count > 0:
		state = States.HOLDING
	elif state == States.HOLDING and BaubleManager.held_count <= 0:
		state = States.IDLE

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

func die():
	SignalBus.emit_signal("player_dead")

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy = area
	if area.is_in_group("hurts_player") && canHit:
		change_health(enemy.damage_dealt)
		flash(6)
	
func flash(count):
	canHit = false
	
	for n in range(count):
		visible = false
		await get_tree().create_timer(0.07).timeout
		visible = true
		await get_tree().create_timer(0.07).timeout
	canHit = true
	
