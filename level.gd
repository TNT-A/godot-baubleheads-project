extends Node2D

@onready var player = Global.player
var player_scene : PackedScene = preload("res://player/player.tscn")
var map : PackedScene = preload("res://cave_tilemap.tscn") 

func _ready() -> void:
	add_child(map.instantiate())
	add_child(player_scene.instantiate())
