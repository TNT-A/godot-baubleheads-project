extends Node2D

@onready var player : Node = Global.player
var current_map : Node 

var this_scene : String = "res://level_manager.tscn"

var player_scene : PackedScene = preload("res://player/player.tscn")
var ui_scene : PackedScene = preload("res://in_game_ui.tscn")
var map_scene : PackedScene 

func _ready() -> void:
	SignalBus.scene_transition.connect(switch_maps)
	choose_map()
	var new_area = map_scene.instantiate()
	self.add_child(ui_scene.instantiate())
	self.add_child(player_scene.instantiate())
	self.add_child(new_area)
	current_map = new_area

func choose_map():
	map_scene = preload("res://Maps/cave_tilemap.tscn") 

func switch_maps():
	get_tree().change_scene_to_file(this_scene)
