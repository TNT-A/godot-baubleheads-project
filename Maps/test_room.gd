extends Node2D

var player_scene : PackedScene = preload("res://player/player.tscn")
@onready var player_spawn_position = $PlayerSpawn.global_position

func _ready() -> void:
	spawn_player()

func spawn_player():
	var new_player = player_scene.instantiate()
	self.add_child(new_player)
	new_player.global_position = player_spawn_position
