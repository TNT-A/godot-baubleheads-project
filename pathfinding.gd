extends Node2D

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

@export var host : CharacterBody2D
@export var target_node : Node
@export var target_vector_position : Vector2 = Vector2()

@export var speed : int = 150
@export var acceleration : float  = 0.1

func _physics_process(delta: float) -> void:
	pathfinding(speed)
	if is_instance_valid(target_node):
		target_vector_position = target_node.global_position

func pathfinding(speed_change):
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	if host:
		print(dir)
		host.velocity = host.velocity.lerp(dir * speed_change, acceleration)
		host.move_and_slide()
	else:
		print("uhhh")

#Pick random within range of another location 
func random_location(location, range_D):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_position : Vector2 = Vector2()
		random_position.x = location.x + rng.randf_range(-range_D,range_D)
		random_position.y = location.y + rng.randf_range(-range_D,range_D)
		return random_position

#Pick random pivot distance from a target
func random_pivot(range_D):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_pivot : Vector2 = Vector2()
		random_pivot.x = rng.randf_range(-range_D,range_D)
		random_pivot.y = rng.randf_range(-range_D,range_D)
		return random_pivot
	else:
		return Vector2(0, 0)

#Resets the pathfinding path with help of timer 
func make_path():
	if target_vector_position:
		nav_agent.target_position = target_vector_position
		#print('path made')

#Adds a pivot distace from the actual target so that everything pathfinding to it doesn't stack
var target_pivot : Vector2 
var target_decided : bool = false
func new_target(target_position, range_D):
	if target_decided == false:
		target_pivot = Vector2(0,0)
		target_pivot = random_pivot(range_D)
		target_decided = true
	target_vector_position = target_position + target_pivot

#resets the target_pivot value every 2 seconds
var target_timeout = false
func reset_target(range_D):
	if target_timeout == false:
		target_pivot = random_pivot(range_D)
		target_timeout = true
		await get_tree().create_timer(2.0).timeout
		target_timeout = false

func _on_timer_pathfinding_timeout() -> void:
	make_path()
