extends CharacterBody2D

@onready var player : Node = Global.player

var crackshot_scene : PackedScene = preload("res://lots_of_crack.tscn")
var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

@export var health : int = 60

var is_alive : bool = true
var count_attacking : int = 0

var nearby_baubles : Array = []
var attacking_baubles : Array = []

var is_active : bool = true
var crack_spawned : bool = true
var cooldown_done : bool = false
var animation_done : bool = false

var attack_cooldown : float = 5.0
var cooldown_differential : float = 1.5

var drop_chart : Dictionary = {
	"none" : 40,
	"ruby" : 50,
	"sapphire" : 60,
	"topaz" : 100
	}

enum States {IDLE, SHOOT}
var state: States = States.IDLE

func _ready() -> void:
	SignalBus.change_enemy_health.connect(change_health)
	$TimerShotCooldown.wait_time = randf_range(attack_cooldown - cooldown_differential, attack_cooldown + cooldown_differential)
	$TimerShotCooldown.start()
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	state_transition()
	state_functions()
	check_attacking_baubles()
	if is_alive == false:
		die()

func state_transition():
	if state == States.IDLE and cooldown_done:
		state = States.SHOOT
	elif state == States.SHOOT and animation_done:
		state = States.IDLE

func state_functions():
	if state == States.IDLE:
		animation_done = false
		if $TimerShotCooldown.is_stopped():
			$TimerShotCooldown.wait_time = randf_range(attack_cooldown - 1.0, attack_cooldown + 1.0)
			$TimerShotCooldown.start()
			cooldown_done = false
		$AnimatedSprite2D.play("idle")
	if state == States.SHOOT:
		if count_attacking <= 7:
			if $AnimatedSprite2D.animation != "shoot":
				$AnimatedSprite2D.play("shoot")
			if !crack_spawned:
				spawn_crack(player)
				crack_spawned = true
			cooldown_done = false
		elif count_attacking > 7:
			if $AnimatedSprite2D.animation != "shoot":
				$AnimatedSprite2D.play("shoot")
			if !crack_spawned:
				spawn_crack(self)
				crack_spawned = true
			cooldown_done = false

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false
	#print("I'm hurt :( ", health)

func check_attacking_baubles():
	for bauble in nearby_baubles:
		var index = nearby_baubles.find(bauble)
		if !is_instance_valid(nearby_baubles[index]):
			nearby_baubles.remove_at(index)
			#print("removed from nearby list")
	for bauble in attacking_baubles:
		var index = attacking_baubles.find(bauble)
		if !is_instance_valid(attacking_baubles[index]):
			attacking_baubles.remove_at(index)
			#print("removed from attacking list")
	for bauble in nearby_baubles:
		if !attacking_baubles.has(bauble):
			if bauble.state == bauble.States.ATTACK or bauble.state == bauble.States.TARGETING: 
				attacking_baubles.append(bauble)
				#print("added to list")
		elif attacking_baubles.has(bauble):
			if bauble.state != bauble.States.ATTACK and bauble.state != bauble.States.TARGETING: 
				var index = attacking_baubles.find(bauble)
				attacking_baubles.remove_at(index)
				#print("removed from list")
	count_attacking = attacking_baubles.size()

func die():
	drop_item()
	SignalBus.enemy_dead.emit(self)
	call_deferred("queue_free")

func drop_item():
	var drop_chance : int = randi_range(0, 100)
	if drop_chance < drop_chart["none"]:
		#print("none")
		pass
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

func spawn_crack(target_node):
	var crackshot = crackshot_scene.instantiate()
	if target_node:
		var range_max : int = 50
		var random_pivot : Vector2 = Vector2(randi_range(-range_max, range_max), randi_range(-range_max, range_max))
		crackshot.target = target_node.global_position + random_pivot
	else:
		crackshot.target = global_position
	crackshot.global_position = $Marker2D.global_position
	add_child(crackshot)

func _on_timer_shot_cooldown_timeout() -> void:
	cooldown_done = true

func _on_animated_sprite_2d_animation_finished() -> void:
	animation_done = true

func _on_animated_sprite_2d_frame_changed() -> void:
	if $AnimatedSprite2D.animation == "shoot" and $AnimatedSprite2D.frame == 9:
		#print("thats shooting right there")
		crack_spawned = false

func _on_bauble_checker_body_entered(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		nearby_baubles.append(body)

func _on_bauble_checker_body_exited(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		var index = nearby_baubles.find(body)
		nearby_baubles.remove_at(index)
