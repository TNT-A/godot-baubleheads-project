extends Node2D

enum States {GAME, INVENTORY, PAUSED}
var state: States = States.GAME

#var current_level : int = 0

var current_player : Node
var current_map : Node 
var current_ui : Node

var this_scene : PackedScene = preload("res://level_manager.tscn")
var main_menu : PackedScene = preload("res://TitleScreen.tscn")

var player_scene : PackedScene = preload("res://player/player.tscn")
var ui_scene : PackedScene = preload("res://in_game_ui.tscn")
var map_scene : PackedScene 

var level_scenes : Array = [
	#preload("res://Maps/test_level.tscn"),
	#preload("res://Maps/cave_tilemap.tscn"),
	preload("res://Maps/og_level_1.tscn"),
	preload("res://Maps/og_level_2.tscn"),
	preload("res://Maps/og_level_3.tscn"),
	preload("res://Maps/og_level_4.tscn"),
	preload("res://Maps/og_level_5.tscn"),
	preload("res://Maps/og_level_6.tscn"),
	#preload("res://Maps/og_level_7.tscn"),
	#preload("res://Maps/og_level_8.tscn"),
]

var can_continue : bool = false

func _ready() -> void:
	#print("level started")
	SignalBus.scene_transition.connect(switch_maps)
	SignalBus.all_enemies_killed.connect(set_can_continue)
	SignalBus.player_dead.connect(reset_game)
	choose_map()
	create_game_scene()
	BaubleManager.refill_party()
	$FadeToBlack.fade_from_black()
	await $FadeToBlack/AnimationPlayer.animation_finished

func _physics_process(delta: float) -> void:
	change_state()
	send_state_info()

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
	current_player.global_position = current_map.player_spawn_location

func choose_map():
	var level_index = randi_range(0, level_scenes.size()-1)
	map_scene = level_scenes[level_index]

func switch_maps():
	if can_continue:
		#print("sick nasty")
		save_player_stats()
		save_baubles()
		save_bauble_stats()
		save_inventory()
		$FadeToBlack.fade_to_black()
		await $FadeToBlack/AnimationPlayer.animation_finished
		get_tree().call_deferred("change_scene_to_packed", this_scene)

func change_state():
	if state == States.GAME:
		if current_ui.paused:
			state = States.PAUSED
		if current_ui.inventory:
			state = States.INVENTORY
	if state == States.PAUSED:
		if !current_ui.paused:
			state = States.GAME
	if state == States.INVENTORY:
		if !current_ui.inventory:
			state = States.GAME

func send_state_info():
	if state == States.GAME:
		current_player.accept_input = true
		current_ui.can_open_pause = true
		current_ui.can_open_inventory = true
	if state == States.PAUSED:
		current_player.accept_input = false
		current_ui.can_open_pause = true
		current_ui.can_open_inventory = false
	if state == States.INVENTORY:
		current_player.accept_input = true
		current_ui.can_open_pause = true
		current_ui.can_open_inventory = true
	send_bauble_state()

func send_bauble_state():
	for bauble in BaubleManager.bauble_inventory:
		if bauble is Node:
			if state == States.GAME:
				bauble.accept_input = true
			if state == States.PAUSED:
				bauble.accept_input = false
			if state == States.INVENTORY:
				bauble.accept_input = false

func save_player_stats():
	for stat in Global.player_stats:
		Global.player_stats[stat] = current_player.hhealth.current_health

func save_baubles():
	for bauble in BaubleManager.bauble_inventory:
		var target = bauble
		var index = BaubleManager.bauble_inventory.find(bauble)
		if target != null:
			BaubleManager.saved_baubles[index] = BaubleManager.bauble_inventory[index].type_data.type
		elif target == null:
			BaubleManager.saved_baubles[index] = null

func save_bauble_stats():
	for bauble in BaubleManager.bauble_inventory:
		var target = bauble
		var index = BaubleManager.bauble_inventory.find(bauble)
		if target != null:
			var bauble_stats = bauble.bauble_stats
			BaubleManager.bauble_stats_list[index] = bauble_stats
		elif target == null:
			BaubleManager.bauble_stats_list[index] = null

func save_inventory():
	var inventory = current_ui.get_child(1).inventory
	for item in inventory:
		Global.pickup_inventory[item] = inventory[item] 

func set_can_continue():
	can_continue = true

func reset_game():
	$FadeToBlack.fade_to_red()
	await $FadeToBlack/AnimationPlayer.animation_finished
	BaubleManager.saved_baubles = BaubleManager.base_bauble_inventory
	Global.player_stats = Global.base_player_stats
	Global.pickup_inventory = Global.base_pickup_inventory
	if is_instance_valid(get_tree()):
		get_tree().change_scene_to_file("res://TitleScreen.tscn")
