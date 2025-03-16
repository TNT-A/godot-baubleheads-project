extends Node2D

@export var enemy_type : Resource
var enemy_scene : PackedScene = preload("res://enemies/earthworm/earthworm.tscn")

func _ready() -> void:
	
