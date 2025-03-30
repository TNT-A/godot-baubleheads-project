extends CharacterBody2D

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

var target
var has_target : bool = false

var speed : int = 200
var acceleration : float  = 0.1

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	new_target(player.global_position, 50.0)
	reset_target(50)
	if has_target:
		pathfinding(speed)
		$AnimatedSprite2D.rotation = get_angle_to(player.global_position)

func pathfinding(speed_change):
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = velocity.lerp(dir * speed_change, acceleration)
	move_and_slide()

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

func make_path():
	if target:
		nav_agent.target_position = target

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

func _on_timer_pathfinding_timeout() -> void:
	make_path()

func _on_target_detector_body_entered(body: Node2D) -> void:
	if body == player:
		target = body
		has_target = true
		print("cool")
	elif body.is_in_group("bauble"):
		target = body
		has_target = true
		print("cool")
