extends Node2D

@export var enemy_type : Resource
var enemy_scene : PackedScene = preload("res://enemies/earthworm/earthworm.tscn")

func _ready() -> void:
	if enemy_type:
		enemy_scene = enemy_type.idk
	else:
		enemy_scene = preload("res://enemies/earthworm/earthworm.tscn")
	add_child(enemy_scene.instantiate())
