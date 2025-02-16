extends Node

@onready var main = get_tree().current_scene

var bauble_scene : PackedScene = preload("res://Baubles/baublehead.tscn")

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
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Baublehead_Call"):
		var current_index = find_empty_slot()
		if current_index is int and current_index < 10:
			spawn_bauble(current_index)
	if Input.is_action_just_pressed("Baublehead_Kill"):
		var current_index = find_full_slot()
		if current_index is int and current_index < 10:
			despawn_bauble(current_index)
	if Input.is_action_just_pressed("Run"):
		replace_bauble(0)

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
			current_index = bauble_inventory.find(slot) - 1
			break
		elif slot is Node:
			current_index = 9
	return current_index
	pass

func spawn_bauble(bauble):
	var new_bauble = bauble_scene.instantiate()
	var current_index = find_empty_slot()
	if current_index is int and current_index < 10:
		bauble_inventory[current_index] = new_bauble
		main.add_child(new_bauble)
	else:
		pass

func despawn_bauble(bauble):
	var bauble_to_delete = bauble_inventory[bauble]
	if bauble_to_delete != null:
		bauble_to_delete.queue_free()
		bauble_inventory[bauble] = null
	else:
		pass

func replace_bauble(bauble):
	if bauble_inventory[bauble] is Node:
		despawn_bauble(bauble)
		spawn_bauble(bauble)
	elif bauble_inventory[bauble] == null:
		spawn_bauble(bauble)
	else:
		print('Nothing to replace')
