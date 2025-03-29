extends CharacterBody2D
class_name Baublehead

@export var speed : int = 250
@export var acceleration : float = .1
@export var deceleration : float = .05
@export var type : Resource

@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var player : Node = Global.player

enum States {IDLE, FOLLOW, PATROL, TARGETING, ATTACK, HELD, THROWN, DEFEND, RETURN}
var state: States = States.IDLE

var stats: Dictionary = {
	level = 1,
	exp = 0,
	exp_max = 100,
	level_up_sources = [],
	starting_health = 10,
	health = 10,
	damage = 1, 
	throw_damage = 1,
	max_range = 0.8,
	speed = 250,
	attack_speed = 400,
	attack_cooldown = 1.0
}

var upgrade_values : Dictionary = {
	damage = 1, 
	throw_damage = 3, 
	attack_speed = 20, 
	attack_cooldown = -0.1, 
	max_range = 0.2, 
	starting_health = 1
	}

var accept_input : bool = true

var slot : int = 0
var sprite_height : int = 30
var throw_direction : Vector2 = Vector2(0, 0)
var attack_time_ready : bool = false
var inPlayer : bool = false #checks if bauble is around the player
var inMouse : bool = false
var current_enemy #: Node 
var target : Vector2 
var temp_target : Vector2
var at_range : bool = false
var being_held : bool = false
var in_air : bool = false
var to_be_dropped : bool = false
var to_be_thrown : bool = false
var can_hold : bool = true
var immune : bool = false
var favored_pickup : String

func _ready() -> void:
	$TimerRange.wait_time = stats.max_range
	for bauble in BaubleManager.bauble_inventory:
		if bauble == self:
			slot = BaubleManager.bauble_inventory.find(bauble)
	#incomplete code, should delete itself when player is not real :(
	#if !is_instance_valid(player):
		#BaubleManager.despawn_bauble(slot)
		#print("hi :D ", slot)
		#self.free()
		#print("I'm dead XD")
	load_stats()
	if type == null:
		type = load("res://Baubles/bauble_resources/diamond_bauble.tres")
	favored_pickup = "pickup_" + type.type
	$Sprite2D.texture = type.sprite
	$Sprite2D.scale = Vector2(2,2)
	self.position = random_location(player.position, 30.0)

func load_stats():
	if BaubleManager.bauble_stats_list[slot] != null:
		stats = BaubleManager.bauble_stats_list[slot]

func _physics_process(delta: float) -> void:
	speed = player.stats.speed
	lose_enemy()
	state_transition()
	state_functions()

#player ability 2 is right click
func state_transition():
	if state != States.IDLE and !accept_input:
		state = States.FOLLOW
	if state == States.IDLE and inPlayer == false:
		state = States.FOLLOW
		state_changed()
	elif (state == States.FOLLOW or state == States.RETURN) and inPlayer:
		state = States.IDLE
		state_changed()
	elif (state == States.FOLLOW or state == States.IDLE or States.RETURN) and Input.is_action_pressed("Player_Ability_2") and accept_input:
		state = States.PATROL
		state_changed()
	elif state == States.PATROL and !Input.is_action_pressed("Player_Ability_2") and accept_input:
		if detect_enemy():
			state = States.TARGETING
		elif !detect_enemy():
			state = States.RETURN
		state_changed()
	elif (state == States.TARGETING or state == States.ATTACK or state == States.THROWN) and Input.is_action_just_pressed("Crackhead_Call") and accept_input:
		state = States.RETURN
		state_changed()
	elif state == States.TARGETING and detect_enemy() == false:
		state = States.RETURN
		state_changed()
	elif state == States.TARGETING and attack_time_ready:
		state = States.ATTACK
		state_changed()
	elif state == States.ATTACK:
		if attack_time_ready == false:
			state = States.TARGETING
		elif current_enemy == null:
			state = States.TARGETING
			state_changed()
	if state == States.FOLLOW or state == States.IDLE or state == States.RETURN:
		if Input.is_action_pressed("Player_Ability_1") and inPlayer and accept_input and can_hold and !BaubleManager.throwing:
			state = States.HELD
			state_changed()
	if state == States.HELD and to_be_dropped:
		state = States.RETURN
	if state == States.HELD and to_be_thrown and accept_input:
		state = States.THROWN
		state_changed()
	if state == States.THROWN:
		if !in_air:
			state = States.PATROL
			state_changed()

var attack_ready : bool = true
func state_functions():
	if state == States.FOLLOW:
		new_target(player.global_position, 50.0)
		reset_target(50)
		pathfinding(speed)
		$AnimationPlayer.play("walk")
	if state == States.RETURN:
		new_target(player.global_position, 50.0)
		reset_target(50)
		pathfinding(speed*1.25)
		$AnimationPlayer.play("walk")
		current_enemy = null
		to_be_dropped = false
	if state == States.IDLE:
		reset_velocity()
		$AnimationPlayer.play("idle")
	if state == States.PATROL:
		new_target(get_global_mouse_position(), 20.0)
		var random_speed : float = randf_range(1.3, 1.6)
		#temp_target = get_global_mouse_position()
		if !inMouse:
			reset_target(50)
			pathfinding(speed*random_speed)
		else:
			reset_velocity()
		#clicking a position will make them go there, not just dragging mouse
		#if Input.is_action_just_released("Player_Ability_2"):
			#temp_target = get_global_mouse_position()
			#pass
		$AnimationPlayer.play("walk")
	if state == States.TARGETING:
		immune = true
		if $TimerAttackCooldown.is_stopped():
			if stats.attack_cooldown > 0.1:
				$TimerAttackCooldown.wait_time = randf_range(stats.attack_cooldown - 0.1, stats.attack_cooldown + 0.1)
			else:
				$TimerAttackCooldown.wait_time = 0.00001
			$TimerAttackCooldown.start()
		$AnimationPlayer.play("walk")
		$Sprite2D.scale = Vector2(2,2)
		if current_enemy != null:
			new_target(current_enemy.global_position, 50.0)
		pathfinding(speed)
	if state == States.ATTACK:
		immune = true
		$Sprite2D.scale = Vector2(3,3)
		attack_enemy()
		$AnimationPlayer.play("attack")
	if state == States.HELD:
		immune = true
		$AnimationPlayer.play("sit")
		var stack_position : int = BaubleManager.held_baubles.find(self)
		carry(stack_position * sprite_height)
	if state == States.THROWN:
		immune = true
		$AnimationPlayer.play("thrown")
		thrown()

func state_changed():
	target_decided = false
	being_held = false
	enable_collision()
	$TimerAttackCooldown.stop()
	$TimerRange.stop()
	$Sprite2D.rotation = 0
	$Sprite2D.scale = Vector2(2, 2)
	immune = false
	#print("state changed ", state)

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

func reset_velocity():
	velocity = velocity.lerp(Vector2.ZERO,deceleration)
	move_and_slide()
	if player.position > position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = false
	if player.position < position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = true

func detect_enemy():
	var inEnemy : bool = false
	if current_enemy != null:
		inEnemy = true
	else:
		inEnemy = false
	return inEnemy

var attack_speed_timeout : bool = false
func attack_enemy():
	var direction : Vector2 
	#var range : Vector2 = Vector2(3,3)
	var max_enemy_distance : Vector2 = Vector2(50,50)
	var enemy_position : Vector2 = current_enemy.global_position
	var target_position : Vector2 = enemy_position + (enemy_position - global_position)
	var distance : Vector2 
	if attack_speed_timeout == false and attack_ready :
		$Sprite2D.rotation = get_angle_to(current_enemy.global_position)
		direction = (target_position - global_position).normalized()
		velocity = (stats.attack_speed * direction)
		attack_ready = false
	distance = abs(enemy_position - global_position)
	if distance.x >= max_enemy_distance.x or distance.y >= max_enemy_distance.y:
		reset_velocity()
		SignalBus.emit_signal("change_enemy_health", current_enemy, stats.damage)
		attack_ready = true
		attack_time_ready = false
	else:
		move_and_slide()

func carry(height):
	in_air = true
	at_range = false
	$Sprite2D.flip_h = player.sprite.flip_h
	disable_collision()
	global_position = player.hand_marker.global_position - Vector2(0, height)
	target = get_global_mouse_position()
	throw_direction = (target-global_position).normalized()
	being_held = true

func thrown():
	if $TimerRange.is_stopped():
		$TimerRange.wait_time = stats.max_range
		#print($TimerRange.wait_time)
		$TimerRange.start()
	in_air = true
	velocity = (stats.attack_speed*throw_direction)
	move_and_slide()
	if is_on_wall() or at_range:
		velocity = Vector2(0, 0)
		in_air = false
		to_be_thrown = false

func pathfinding(speed_change):
	var next_path_pos := nav_agent.get_next_path_position()
	var dir := global_position.direction_to(next_path_pos)
	velocity = velocity.lerp(dir * speed_change, acceleration)
	if player.position > position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = false
	if player.position < position and abs(position.x - player.position.x) > 20:
		$Sprite2D.flip_h = true
	move_and_slide()

func make_path():
	if target:
		nav_agent.target_position = target
	else:
		nav_agent.target_position = player.global_position

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

func add_xp(source):
	var exp_needed = stats.exp_max
	var ammount : int = 0
	if source == "enemy":
		ammount = 20
	if source == "room":
		ammount = 30
	if source == "pickup_ruby" or source == "pickup_sapphire" or source == "pickup_topaz":
		ammount = 50
	if source == favored_pickup:
		ammount += 25
	if source == "level":
		ammount == 100
	stats.exp += ammount
	stats.level_up_sources.append(source)
	#print("exp added ", + ammount)
	if stats.exp >= exp_needed:
		level_up()
		stats.exp = 0

func level_up():
	stats.level += 1
	stats.exp_max = 100 + roundi(10 * 1.3 ** stats.level)
	add_stats()
	stats.level_up_sources.clear()
	reset_health()
	#print("I'M LEVELING UP BABY WOOOOO YEAAAAA ", + stats.exp_max)

func add_stats():
	var upgradable_stats : Dictionary = {
		damage = 10, 
		throw_damage = 10, 
		attack_speed = 10, 
		attack_cooldown = 10, 
		max_range = 10, 
		starting_health = 10
		}
	for source in stats.level_up_sources:
		if source == "pickup_ruby":
			upgradable_stats.damage += 30
		if source == "pickup_sapphire":
			upgradable_stats.throw_damage += 30
		if source == "pickup_topaz":
			upgradable_stats.attack_speed += 30
			upgradable_stats.attack_cooldown += 30
		if source == "enemy" or source == "room":
			upgradable_stats.damage += 5
			upgradable_stats.throw_damage += 5
			upgradable_stats.attack_speed += 5
			upgradable_stats.attack_cooldown += 5
			upgradable_stats.max_range += 5
			upgradable_stats.starting_health += 5
		if source == "level":
			upgradable_stats.damage += 20
			upgradable_stats.throw_damage += 20
			upgradable_stats.attack_speed += 20
			upgradable_stats.attack_cooldown += 20
			upgradable_stats.max_range += 20
			upgradable_stats.starting_health += 20
	for stat in upgradable_stats:
		var random_value : int = randi_range(0, 100)
		if upgradable_stats[stat] >= random_value:
			stats[stat] += upgrade_values[stat]
			if upgradable_stats[stat] >= random_value * 2:
				stats[stat] += upgrade_values[stat]
			#print("upgraded ", stat)
	for stat in upgradable_stats:
		upgradable_stats[stat] = 10

func lose_enemy():
	if is_instance_valid(current_enemy):
		pass
	else:
		current_enemy = null

func disable_collision():
	$CollisionShape2D.disabled = true

func enable_collision():
	$CollisionShape2D.disabled = false

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = true
	if body.is_in_group("enemy") and (state == States.PATROL or state == States.THROWN):
		current_enemy = body
	if body.is_in_group("enemy") and state == States.THROWN:
		SignalBus.emit_signal("change_enemy_health", body, stats.throw_damage * 3)

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == player:
		inPlayer = false

func _on_area_2d_mouse_entered() -> void:
	inMouse = true

func _on_area_2d_mouse_exited() -> void:
	inMouse = false

func _on_timer_timeout() -> void:
	make_path()

func _on_timer_range_timeout() -> void:
	at_range = true

func _on_timer_attack_cooldown_timeout() -> void:
	attack_time_ready = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy = area
	if area.is_in_group("hurts_player"):
		change_health(enemy.damage_dealt)

func change_health(change):
	if !immune:
		stats.health -= change
		if stats.health <= 0:
			stats.health = 0
			die()
		#print(stats.health)

func reset_health():
	stats.health = stats.starting_health

func die():
	BaubleManager.despawn_bauble(slot)
