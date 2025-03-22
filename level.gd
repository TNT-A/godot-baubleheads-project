extends Node2D

#@onready var player : Node = Global.player
var current_player : Node
var current_map : Node 
var current_ui : Node

var this_scene : PackedScene = preload("res://level_manager.tscn")

var player_scene : PackedScene = preload("res://player/player.tscn")
var ui_scene : PackedScene = preload("res://in_game_ui.tscn")
var map_scene : PackedScene 

func _ready() -> void:
	print("level started")
	SignalBus.scene_transition.connect(switch_maps)
	choose_map()
	create_game_scene()
	BaubleManager.refill_party()
	$FadeToBlack.fade_from_black()
	await $FadeToBlack/AnimationPlayer.animation_finished

func create_game_scene():
	var new_ui = ui_scene.instantiate()
	var new_player = player_scene.instantiate()
	var new_area = map_scene.instantiate()
	self.add_child(new_ui)
	self.add_child(new_player)
	self.add_child(new_area)
	current_map = new_area
	current_player = new_player
	current_ui = new_ui

func choose_map():
	map_scene = preload("res://Maps/cave_tilemap.tscn") 

func switch_maps():
	$FadeToBlack.fade_from_black()
	await $FadeToBlack/AnimationPlayer.animation_finished
	print("sick nasty")
	save_player_stats()
	save_baubles()
	save_inventory()
	get_tree().call_deferred("change_scene_to_packed", this_scene)

func save_player_stats():
	for stat in Global.player_stats:
		Global.player_stats[stat] = current_player.stats[stat]

func save_baubles():
	for bauble in BaubleManager.bauble_inventory:
		var target = bauble
		var index = BaubleManager.bauble_inventory.find(bauble)
		if target != null:
			BaubleManager.saved_baubles[index] = BaubleManager.bauble_inventory[index].type.type
		elif target == null:
			BaubleManager.saved_baubles[index] = null

func save_inventory():
	var inventory = current_ui.get_child(3).inventory
	for item in inventory:
		Global.pickup_inventory[item] = inventory[item] 
