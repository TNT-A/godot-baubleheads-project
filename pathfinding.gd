extends Node2D

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

## This var determines if the host will start pathfinding immediatly
@export var active : bool = true
## This var determines who the host is (characterbody2D)
@export var host : CharacterBody2D

@export_group("Targeting") 
## This var lets you determine the initial target of the host
@export var target_node : Node
## This var lets you determine the initial target position of the host (does nothing I think)
@export var target_vector_position : Vector2 = Vector2()
## This var makes the host immediately target the player rather than any other scene
@export var chase_player : bool = true

@export_group("Speed Values") 
## Controls speed of host pathfinding
@export var speed : int = 150
## Controls how long it takes for the host to reach max speed
@export var acceleration : float  = 0.1
## Controls how long it takes to decelerate after moving 
@export var deceleration : float  = 0.2

@export_group("Resetting Target + Choosing Pivot") 
## Controls how long before the target position is shifted to a new pivot
@export var reset_time : float = 2.0
## Controls the pivot distance max (so the various pathfinding objects don't stack
@export var pivot_range : float = 10.0

@export_group("Stopping Logic") 
## Controls the distance maximum before the objects stops pathfinding to it's target
@export var stop_range : float = 15.0

var has_target : bool = true
var target_pivot : Vector2 
var target_decided : bool = false

func _ready() -> void:
	$TimerTargetReset.wait_time = reset_time
	$TimerTargetReset.start()
	if chase_player:
		target_node = player
	if target_node == null:
		has_target = false
		print("I am targetless :pensive:")

func _physics_process(delta: float) -> void:
	if active:
		pathfinding(speed)
	if !active:
		reset_velocity()
	if has_target:
		target_vector_position = target_node.global_position
	if target_node == null:
		has_target = false
	new_target(target_node.global_position, pivot_range)

func pathfinding(speed_change):
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	if host:
		host.velocity = host.velocity.lerp(dir * speed_change, acceleration)
		host.move_and_slide()

#Checks if the host is within a certain distance of their target
func check_distance():
	var distance = global_position.distance_to(target_vector_position)
	#print(distance)
	if distance <= stop_range:
		active = false
	elif distance > stop_range:
		active = true

func reset_velocity():
	host.velocity = host.velocity.lerp(Vector2.ZERO,deceleration)
	host.move_and_slide()

#Pick random within range of another location 
func random_location(location, range_D):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_position : Vector2 = Vector2()
		random_position.x = location.x + rng.randf_range(-range_D,range_D)
		random_position.y = location.y + rng.randf_range(-range_D,range_D)
		return random_position

#Resets the pathfinding path with help of timer 
func make_path():
	if target_vector_position:
		nav_agent.target_position = target_vector_position

#Adds a pivot distace from the actual target so that everything pathfinding to it doesn't stack
func new_target(target_position, range_D):
	if target_decided == false:
		target_pivot = Vector2(0,0)
		target_pivot = random_pivot(range_D)
		target_decided = true
		#print(target_decided)
	target_vector_position = target_position + target_pivot
	#print(target_vector_position, " ", target_position)

#resets the target_pivot value every 2 seconds
func reset_target(range_D):
	target_pivot = random_pivot(range_D)

#Pick random pivot distance from a target
func random_pivot(range_D):
	var rng = RandomNumberGenerator.new()
	var random_pivot : Vector2 = Vector2()
	random_pivot.x = rng.randf_range(-range_D,range_D)
	random_pivot.y = rng.randf_range(-range_D,range_D)
	return random_pivot

func _on_timer_pathfinding_timeout() -> void:
	make_path()
	check_distance()

func _on_timer_target_reset_timeout() -> void:
	reset_target(pivot_range)
	#print("timer out")
