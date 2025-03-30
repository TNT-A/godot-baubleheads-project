extends CharacterBody2D

@onready var player : Node = Global.player

var crackshot_scene : PackedScene = preload("res://lots_of_crack.tscn")

var is_active : bool = true
var crack_spawned : bool = true
var cooldown_done : bool = false
var animation_done : bool = false
var attack_cooldown : float = 3.0

enum States {IDLE, SHOOT}
var state: States = States.IDLE

func _ready() -> void:
	$TimerShotCooldown.wait_time = attack_cooldown
	$TimerShotCooldown.start()
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	state_transition()
	state_functions()

func state_transition():
	if state == States.IDLE and cooldown_done:
		state = States.SHOOT
	elif state == States.SHOOT and animation_done:
		state = States.IDLE

func state_functions():
	if state == States.IDLE:
		animation_done = false
		if $TimerShotCooldown.is_stopped():
			$TimerShotCooldown.start()
			cooldown_done = false
		$AnimatedSprite2D.play("idle")
	if state == States.SHOOT:
		if $AnimatedSprite2D.animation != "shoot":
			$AnimatedSprite2D.play("shoot")
		if !crack_spawned:
			spawn_crack()
			crack_spawned = true
		cooldown_done = false

func spawn_crack():
	var crackshot = crackshot_scene.instantiate()
	if player:
		crackshot.target = player.global_position
	else:
		crackshot.target = global_position + Vector2(0, 100)
	crackshot.global_position = $Marker2D.global_position
	add_child(crackshot)

func _on_timer_shot_cooldown_timeout() -> void:
	cooldown_done = true

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_done = true

func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "shoot" and $AnimatedSprite2D.frame == 9:
		print("thats shooting right there")
		crack_spawned = false
