extends Node

@onready var main = get_tree().current_scene

var bauble_scene : PackedScene = preload("res://Baubles/baublehead.tscn")

var bauble_types : Dictionary = {
	"ruby" : "res://Baubles/bauble_resources/ruby_bauble.tres", 
	"sapphire" : "res://Baubles/bauble_resources/sapphire_bauble.tres", 
	"topaz" : "res://Baubles/bauble_resources/topaz_bauble.tres", 
	"emerald" : "res://Baubles/bauble_resources/emerald_bauble.tres", 
	"opal" : "res://Baubles/bauble_resources/opal_bauble.tres", 
	"diamond" : "res://Baubles/bauble_resources/diamond_bauble.tres",
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

func _ready() -> void:
	SignalBus.item_used.connect(determine_bauble_control)
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Baublehead_Call"):
		var current_index = find_empty_slot()
		if current_index is int and current_index < 10:
			spawn_bauble("opal", current_index)
	if Input.is_action_just_pressed("Baublehead_Kill"):
		var current_index = find_full_slot()
		print(current_index)
		if current_index is int and current_index < 10:
			despawn_bauble(current_index)
	if Input.is_action_just_pressed("Run"):
		replace_bauble("opal", 0)

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
		if slot is not Node:
			pass
		elif slot is Node:
			current_index = bauble_inventory.find(slot)
			break
	return current_index

func determine_bauble_control(item, party_slot):
	var item_type = item.type 
	replace_bauble(item_type, party_slot)

func spawn_bauble(type_of_bauble, slot):
	var new_bauble = bauble_scene.instantiate()
	if slot is int and slot < 10:
		bauble_inventory[slot] = new_bauble
		new_bauble.type = load(bauble_types[type_of_bauble])
		main.add_child(new_bauble)
	else:
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
		print('Nothing to replace')
