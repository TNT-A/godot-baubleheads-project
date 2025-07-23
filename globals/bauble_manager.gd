extends Node

@onready var main = get_tree().current_scene
@onready var player : Node = Global.player

var bauble_scene : PackedScene = preload("res://baubles/bauble.tscn")
var held_count : int = 0
var max_bauble_count : int = 3
var max_baubles_held : bool = false
var throw_cooldown : float = 0.5
var throwing : bool = false

var bauble_types : Dictionary = {
	"ruby" : "res://baubles/bauble_type_resources/bauble_ruby.tres", 
	"sapphire" : "res://baubles/bauble_type_resources/bauble_sapphire.tres", 
	"topaz" : "res://baubles/bauble_type_resources/bauble_topaz.tres", 
	"emerald" : "res://baubles/bauble_type_resources/bauble_emerald.tres", 
	"opal" : "res://baubles/bauble_type_resources/bauble_opal.tres", 
	"diamond" : "res://baubles/bauble_type_resources/bauble_diamond.tres",
	}

var bauble_inventory : Array = [
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null
]

var base_bauble_inventory : Array = [
	"ruby",
	"sapphire",
	"topaz",
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

var saved_baubles : Array = [
	"ruby",
	"sapphire",
	"topaz",
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

var bauble_stats_template : Dictionary = {
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

var bauble_stats_list : Array = [
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
	null,
]

var held_baubles : Array
var to_be_held : Array

func _ready() -> void:
	SignalBus.item_used.connect(determine_bauble_control)

func _physics_process(delta: float) -> void:
	main = get_tree().current_scene
	#count_held()
	held_count = held_baubles.size()
	if Input.is_action_just_released("Player_Ability_1"):
		choose_thrown()
	if Input.is_action_just_pressed("Spawn_Bauble"):
		var current_index = find_empty_slot()
		if current_index is int and current_index < 10:
			spawn_bauble("ruby", current_index)
	if Input.is_action_just_pressed("Kill_Bauble"):
		var current_index = find_full_slot()
		#print(current_index)
		if current_index is int and current_index < 10:
			despawn_bauble(current_index)
	if Input.is_action_just_pressed("Replace_Bauble"):
		replace_bauble("ruby", 0)

func find_empty_slot():
	var current_index
	for slot in bauble_inventory:
		if slot == null:
			current_index = bauble_inventory.find(slot) 
			break
	return current_index

func find_full_slot():
	var current_index
	for slot in bauble_inventory:
		if slot is not Node: # slot == null:
			pass
		elif slot is Node:
			current_index = bauble_inventory.find(slot)
			break
	return current_index

func determine_bauble_control(item, party_slot):
	var item_type = item.type 
	var pickup_type = "pickup_" + item_type
	if bauble_inventory[party_slot] is Node:
		bauble_inventory[party_slot].add_xp(pickup_type)
	else:
		replace_bauble(item_type, party_slot)

func refill_party():
	main = get_tree().current_scene
	var slot_count = bauble_inventory.size()
	for index in slot_count:
		#var index = saved_baubles.find(bauble)
		var bauble = saved_baubles[index]
		if saved_baubles[index] != null:
			spawn_bauble(bauble, index)
			#print("real")
		elif saved_baubles[index] == null:
			bauble_inventory[index] = null
			#print("ICANT")
	#print("refill done")
	#print(bauble_inventory)

func spawn_bauble(type_of_bauble, slot):
	var new_bauble = bauble_scene.instantiate()
	if slot is int and slot < 10:
		bauble_inventory[slot] = new_bauble
		new_bauble.type_data = load(bauble_types[type_of_bauble])
		main.add_child(new_bauble)
		#print("okay :D")
	else:
		#print("nuh-uh")
		pass

func despawn_bauble(slot):
	var bauble_to_delete = bauble_inventory[slot]
	if bauble_to_delete != null:
		bauble_to_delete.queue_free()
		bauble_inventory[slot] = null
	else:
		pass

func replace_bauble(type_of_bauble, slot):
	if bauble_inventory[slot] is Node:
		despawn_bauble(slot)
		spawn_bauble(type_of_bauble, slot)
	elif bauble_inventory[slot] == null:
		spawn_bauble(type_of_bauble, slot)
	else:
		#print('Nothing to replace')
		pass

#func count_held():
	##add and remove held baubles from the held list
	#for bauble in bauble_inventory:
		#if is_instance_valid(bauble):
			#if bauble.being_held:
				#if !held_baubles.has(bauble):
					#held_baubles.append(bauble)
			#elif !bauble.being_held:
				#if held_baubles.has(bauble):
					#var index = held_baubles.find(bauble)
					#held_baubles.remove_at(index)
	#for held_bauble in held_baubles:
		#if !is_instance_valid(held_bauble):
			#var index = held_baubles.find(held_bauble)
			#held_baubles.remove_at(index)
	##manage baubles above bauble maximum
	#if held_baubles.size() >= max_bauble_count:
		#for bauble in bauble_inventory:
			#if bauble is Node:
				#bauble.can_hold = false
				#if held_baubles.find(bauble) >= max_bauble_count:
					#bauble.to_be_dropped = true
	#else:
		#for bauble in bauble_inventory:
			#if is_instance_valid(bauble):
				#bauble.can_hold = true

var bauble_distances : Dictionary = {
	
}

func set_distances():
	if !is_instance_valid(player):
		player = Global.player
	if is_instance_valid(player):
		for bauble in bauble_inventory:
			if is_instance_valid(bauble):
				var distance = bauble.global_position.distance_to(player.global_position)
				bauble_distances[bauble] = distance

func choose_thrown():
	if !is_instance_valid(player):
		player = Global.player
	if is_instance_valid(player):
		set_distances()
		var selected_bauble
		var lowest_distance : float = 999999.0
		for bauble in bauble_distances:
			if is_instance_valid(bauble) and bauble.can_throw == true:
				var distance = bauble_distances[bauble]
				if distance < lowest_distance:
					selected_bauble = bauble
					lowest_distance = distance
				#print("New Closest: ", selected_bauble, ": ", distance)
		#print("Trying to throw: ", selected_bauble)
		if is_instance_valid(selected_bauble):
			selected_bauble.thrown = true
			selected_bauble = null
