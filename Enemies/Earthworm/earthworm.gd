extends Node2D

@export var health : int = 50

var crackshot: PackedScene = preload("res://enemies/earthworm/crackshot.tscn")
var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

var under_attack : bool = false
var is_alive : bool = true
var attack_time : bool = false
enum States {IDLE, ATTACK, MOVE}
var state: States = States.ATTACK
var playerCrackable : bool = false
var timer_cooldown : float = 1.6

var drop_chart : Dictionary = {
	"none" : 40,
	"ruby" : 60,
	"sapphire" : 80,
	"topaz" : 100
}

func _ready():
	SignalBus.change_enemy_health.connect(change_health)

func _physics_process(delta: float) -> void:
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
			$TimerAttackCooldown.wait_time = randf_range(timer_cooldown - 0.1, timer_cooldown + 0.1)
			$TimerAttackCooldown.start()
		if attack_time:
			shoot()
			attack_time = false

func shoot():
	add_child(crackshot.instantiate())
	#Global.player.global_position 

func change_health(enemy, change):
	if self == enemy:
		health -= change
	if health <= 0:
		health = 0
		is_alive = false

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

func die():
	drop_item()
	queue_free()

func _on_timer_attack_cooldown_timeout():
	if playerCrackable:
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
