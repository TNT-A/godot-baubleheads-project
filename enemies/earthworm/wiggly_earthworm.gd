extends CharacterBody2D

var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

@export var health : int = 9

var target
var has_target : bool = false
var is_alive : bool = true
var cooldown_done : bool = false
var windup_done : bool = false
var dash_done : bool = false

var dash_length : float = 1.5
var dash_windup_length : float = 0.5
var dash_cooldown : float = 4.0
var dash_dir : Vector2 
var dash_speed : int = 400

var count_attacking : int = 0

var nearby_baubles : Array = []
var attacking_baubles : Array = []

var drop_chart : Dictionary = {
	"none" : 40,
	"ruby" : 50,
	"sapphire" : 60,
	"topaz" : 100
	}

var speed : int = 150
var acceleration : float  = 0.1

enum States {FOLLOW, WINDUP, DASH}
var state: States = States.FOLLOW

func _ready() -> void:
	SignalBus.change_enemy_health.connect(change_health)
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	state_transition()
	state_functions()
	check_attacking_baubles()
	if is_alive == false:
		die()

func state_transition():
	if state == States.FOLLOW and cooldown_done and has_target:
		state = States.WINDUP
	elif state == States.WINDUP and windup_done:
		state = States.DASH
	elif state == States.DASH and dash_done:
		state = States.FOLLOW

func state_functions():
	if state == States.FOLLOW:
		if $TimerDashCooldown.is_stopped() and has_target:
			$TimerDashCooldown.wait_time = randf_range(dash_cooldown - 1.0, dash_cooldown + 1.0)
			$TimerDashCooldown.start()
		dash_done = false
		new_target(player.global_position, 50.0)
		reset_target(50)
		if has_target:
			pathfinding(speed)
			$AnimatedSprite2D.rotation = get_angle_to(player.global_position)
	if state == States.WINDUP:
		cooldown_done = false
		if $TimerDashWindup.is_stopped():
			$TimerDashWindup.wait_time = dash_windup_length
			$TimerDashWindup.start()
			dash_dir = (player.global_position - global_position).normalized()
			$AnimatedSprite2D.rotation = get_angle_to(player.global_position)
	if state == States.DASH:
		windup_done = false
		if $TimerDashLength.is_stopped():
			$TimerDashLength.wait_time = randf_range(dash_length - 0.2, dash_length + 0.2)
			$TimerDashLength.start()
		if is_on_wall() or is_on_ceiling() or is_on_floor():
			dash_done = true
			$TimerDashLength.stop()
		velocity = (dash_dir * dash_speed)
		move_and_slide()

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

func check_attacking_baubles():
	for bauble in nearby_baubles:
		var index = nearby_baubles.find(bauble)
		if !is_instance_valid(nearby_baubles[index]):
			nearby_baubles.remove_at(index)
			print("removed from nearby list")
	for bauble in attacking_baubles:
		var index = attacking_baubles.find(bauble)
		if !is_instance_valid(attacking_baubles[index]):
			attacking_baubles.remove_at(index)
			print("removed from attacking list")
	for bauble in nearby_baubles:
		if !attacking_baubles.has(bauble):
			if bauble.state == bauble.States.ATTACK or bauble.state == bauble.States.TARGETING: 
				attacking_baubles.append(bauble)
				print("added to list")
		elif attacking_baubles.has(bauble):
			if bauble.state != bauble.States.ATTACK and bauble.state != bauble.States.TARGETING: 
				var index = attacking_baubles.find(bauble)
				attacking_baubles.remove_at(index)
				print("removed from list")
	count_attacking = attacking_baubles.size()

func die():
	drop_item()
	queue_free()

func drop_item():
	var drop_chance : int = randi_range(0, 100)
	if drop_chance < drop_chart["none"]:
		print("none")
	elif drop_chart["none"] < drop_chance and drop_chance <= drop_chart["ruby"]:
		create_pickup("ruby")
	elif drop_chart["ruby"] < drop_chance and drop_chance <= drop_chart["sapphire"]:
		create_pickup("sapphire")
	elif drop_chart["sapphire"] < drop_chance and drop_chance <= drop_chart["topaz"]:
		create_pickup("topaz")

func create_pickup(pickup):
	var new_pickup = pickup_scene.instantiate()
	new_pickup.item_resource = load("res://pickups/pickup_resource/item_" + pickup + ".tres")
	get_parent().add_child(new_pickup)
	new_pickup.global_position = global_position

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
		if !has_target:
			$TimerDashCooldown.start()
		target = body.global_position
		has_target = true
	elif body.is_in_group("bauble"):
		if !has_target:
			$TimerDashCooldown.start()
		target = body.global_position
		has_target = true

func _on_bauble_checker_body_entered(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		nearby_baubles.append(body)

func _on_bauble_checker_body_exited(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		var index = nearby_baubles.find(body)
		nearby_baubles.remove_at(index)

func _on_timer_dash_windup_timeout() -> void:
	windup_done = true

func _on_timer_dash_cooldown_timeout() -> void:
	cooldown_done = true

func _on_timer_dash_length_timeout() -> void:
	dash_done = true
