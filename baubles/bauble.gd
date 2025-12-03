extends Node2D

@export var body : CharacterBody2D

@onready var player = Global.player
@onready var state_machine = $StateMachine

var type_data : Resource 
var type_name : String

var bauble_stats : Dictionary = {
	level = 1,
	exp = 0,
	exp_max = 100,
	health = 5,
	damage = 1, 
	throw_damage = 3,
	max_range = 0.8,
	speed = 250,
	attack_speed = 400,
	attack_cooldown = 1.0
}

var accept_input : bool = true
var can_throw : bool = true
var thrown : bool = false

func _ready() -> void:
	z_index = 5
	if player:
		self.global_position = random_location(player.global_position, 30.0)
	if type_data == null:
		type_data = load("res://baubles/bauble_type_resources/bauble_ruby.tres")
	if type_data != null:  
		type_name = type_data.type
	$BaubleBody/Sprite2D.texture = type_data.sprite

func random_location(location, range):
	if player:
		var rng = RandomNumberGenerator.new()
		var random_position : Vector2 = Vector2()
		random_position.x = location.x + rng.randf_range(-range,range)
		random_position.y = location.y + rng.randf_range(-range,range)
		return random_position
