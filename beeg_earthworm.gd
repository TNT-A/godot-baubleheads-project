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
var attack_cooldown : float = 3.0

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
	$TimerShotCooldown.wait_time = attack_cooldown
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

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false
	print("I'm hurt :( ", health)

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
				var index = nearby_baubles.find(bauble)
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
