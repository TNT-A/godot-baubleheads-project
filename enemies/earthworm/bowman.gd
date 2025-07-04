extends Node2D

@onready var player = Global.player

@export var health : int = 30

var crackshot: PackedScene = preload("res://enemies/earthworm/crackshot.tscn")
#var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

var is_alive : bool = true
var attack_time : bool = false
enum States {IDLE, ATTACK, MOVE}
var state: States = States.ATTACK
var playerCrackable : bool = false
var timer_cooldown : float = 1.6
var count_attacking : int = 0

var nearby_baubles : Array = []
var attacking_baubles : Array = []

var drop_chart : Dictionary = {
	"none" : 40,
	"ruby" : 80,
	"sapphire" : 90,
	"topaz" : 100}

func _ready():
	SignalBus.change_enemy_health.connect(change_health)
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	if player:
		if player.global_position < global_position and abs(global_position.x - player.global_position.x) > 20:
			$AnimatedSprite2D.flip_h = true
		if player.global_position > global_position and abs(global_position.x - player.global_position.x) > 20:
			$AnimatedSprite2D.flip_h = false
	check_attacking_baubles()
	if is_alive == false:
		die()
	state_transitions()
	state_functions()

func state_transitions():
	if playerCrackable:
		state = States.ATTACK
	elif true: #change conditional later
		state = States.MOVE

func state_functions():
	if state == States.ATTACK:
		if $TimerAttackCooldown.is_stopped():
			$CharacterBody2D/Bow.play("Reload")
			$TimerAttackCooldown.wait_time = randf_range(timer_cooldown - 0.1, timer_cooldown + 0.1)
			$TimerAttackCooldown.start()
			print("hi")
		if attack_time:
			shoot()
			attack_time = false
	if state == States.MOVE:
		pass
func shoot():
	if count_attacking <= 5:
		$CharacterBody2D/Bow.play("Fire")
		$ShotManager.shoot(1,Vector2(Global.player.global_position.x - position.x, Global.player.global_position.y - position.y).normalized())
		#print(global_position)
		#print("yes")

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
#
#func drop_item():
	#var drop_chance : int = randi_range(0, 100)
	#if drop_chance < drop_chart["none"]:
		##print("none")
		#pass
	#elif drop_chart["none"] < drop_chance and drop_chance <= drop_chart["ruby"]:
		#create_pickup("ruby")
	#elif drop_chart["ruby"] < drop_chance and drop_chance <= drop_chart["sapphire"]:
		#create_pickup("sapphire")
	#elif drop_chart["sapphire"] < drop_chance and drop_chance <= drop_chart["topaz"]:
		#create_pickup("topaz")
#
#func create_pickup(pickup):
	#var new_pickup = pickup_scene.instantiate()
	#new_pickup.item_resource = load("res://pickups/pickup_resource/item_" + pickup + ".tres")
	#get_parent().add_child(new_pickup)
	#new_pickup.global_position = global_position

func die():
	SignalBus.enemy_dead.emit(self)
	call_deferred("queue_free")

func _on_timer_attack_cooldown_timeout():
	if playerCrackable:
		print("I'm reloading!!!!!!!!")
		$CharacterBody2D/Bow.play("Reload")
		attack_time = true

func _on_area_2d_body_shape_entered(body_rid, body: Node2D, body_shape_index, local_shape_index):
	if body == Global.player:
		playerCrackable = true

func _on_area_2d_body_shape_exited(body_rid, body: Node2D, body_shape_index, local_shape_index):
	if body == Global.player:
		playerCrackable = false
		$TimerAttackCooldown.stop()
		$TimerAttackCooldown.wait_time = randf_range(1.2, 2.0)
		attack_time = false

func _on_bauble_checker_body_entered(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		nearby_baubles.append(body)

func _on_bauble_checker_body_exited(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		var index = nearby_baubles.find(body)
		nearby_baubles.remove_at(index)
