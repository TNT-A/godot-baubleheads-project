extends Node2D

@onready var player = Global.player

var player_scene : PackedScene = preload("res://player/player.tscn")
var map_scene : PackedScene = preload("res://Maps/cave_tilemap.tscn") 
var ui_scene : PackedScene = preload("res://in_game_ui.tscn")

func _ready() -> void:
	add_child(map_scene.instantiate())
	add_child(ui_scene.instantiate())
	add_child(player_scene.instantiate())
