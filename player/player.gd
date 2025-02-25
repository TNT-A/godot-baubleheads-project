extends CharacterBody2D

@export var speed : int = 200
@export var acceleration : float = .1
@export var deceleration : float = .1

var health = Max_Health
const Max_Health = 5

enum States {IDLE, WALKING, RUNNING}
var state: States = States.IDLE

signal health_changed(damage)

func change_health(change):
	health -= change
	if health <= 0:
		health = 0
	set_health_bar()

func set_health_bar() -> void:
	$HealthBar.value = health

func _ready() -> void:
	SignalBus.picked_up.connect(test)
	$"/root/Global".register_player(self)
	set_health_bar()
	$HealthBar.max_value = Max_Health

func _physics_process(delta: float) -> void:
	state_transition()
	#print(state)
	if state == States.IDLE:
		reset_velocity()
	if state == States.WALKING:
		walk()

func state_transition():
	if state == States.IDLE and check_for_input() == true:
		state = States.WALKING
	elif state == States.WALKING and check_for_input() == false:
		state = States.IDLE

func check_for_input():
	var isButtonPressed : bool = false
	if Input.is_action_pressed("Move_Left") or Input.is_action_pressed("Move_Right") or Input.is_action_pressed("Move_Down") or Input.is_action_pressed("Move_Up"):
		isButtonPressed = true
	else:
		isButtonPressed = false
	return isButtonPressed

func get_direction():
	var input : Vector2 = Vector2()
	if Input.is_action_pressed("Move_Up"):
		input.y -=1
	if Input.is_action_pressed("Move_Down"):
		input.y +=1
	if Input.is_action_pressed("Move_Left"):
		input.x -=1
	if Input.is_action_pressed("Move_Right"):
		input.x +=1
	return input

func reset_velocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	#velocity = Vector2(0,0)

func walk():
	var direction : Vector2 = get_direction()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO,deceleration)
	if velocity.x > 0:
		get_node("%Sprite2D").flip_h = false
	elif velocity.x < 0:
		get_node("%Sprite2D").flip_h = true
	move_and_slide()
	#print(velocity)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy = area
	if area.is_in_group("hurts_player"):
		change_health(enemy.damage_dealt)
		print(enemy.damage_dealt)

func test(item):
	print(item)
