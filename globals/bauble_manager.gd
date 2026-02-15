extends Node

@onready var main = get_tree().current_scene
@onready var player : Node = Global.player

var bauble_scene : PackedScene = preload("res://baubles/bauble.tscn")
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

#The currently selected bauble type (for the baubles the player is actively controlling)
var selected_type : String = "ruby"

#Inventories for each bauble type
var bauble_inventory_ruby : Array = []
var bauble_inventory_sapphire : Array = []
var bauble_inventory_topaz : Array = []

#Distance lists for each bauble type (for finding the closest bauble
var bauble_distances_ruby : Dictionary = {}
var bauble_distances_sapphire : Dictionary = {}
var bauble_distances_topaz : Dictionary = {}

var default_baubles : Dictionary = {
	"ruby" = 1,
	"sapphire" = 1,
	"topaz" = 1,
}

var saved_baubles : Dictionary = {
	"ruby" = 3,
	"sapphire" = 1,
	"topaz" = 1,
}

#Returns an array of every active bauble
func all_baubles():
	var full_inventory : Array = []
	full_inventory.append_array(bauble_inventory_ruby)
	full_inventory.append_array(bauble_inventory_sapphire)
	full_inventory.append_array(bauble_inventory_topaz)
	return full_inventory

func _ready() -> void:
	SignalBus.item_used.connect(determine_bauble_control)

func _physics_process(delta: float) -> void:
	main = get_tree().current_scene
	if Input.is_action_just_released("Player_Ability_1"):
		choose_thrown()
	if Input.is_action_just_released("Spawn_Bauble"):
		spawn_bauble("ruby")
	if Input.is_action_just_released("Kill_Bauble"):
		despawn_bauble("ruby")

#Something to do with using items idk
func determine_bauble_control(item, party_slot):
	var item_type = item.type 
	var pickup_type = "pickup_" + item_type

#Spawns the default baubles and resets all the saved data
func refill_party():
	main = get_tree().current_scene
	for current_type in saved_baubles:
		for num in saved_baubles[current_type]:
			spawn_bauble(current_type)

#Saves the number or each bauble the player has in order to respawn them later
func save_party():
	saved_baubles["ruby"] = bauble_inventory_ruby.size()
	saved_baubles["sapphire"] = bauble_inventory_ruby.size()
	saved_baubles["topaz"] = bauble_inventory_ruby.size()

#Spawns a bauble of a given type 
func spawn_bauble(type_of_bauble):
	var new_bauble = bauble_scene.instantiate()
	get("bauble_inventory_" + type_of_bauble).append(new_bauble)
	new_bauble.type_data = load(bauble_types[type_of_bauble])
	main.add_child(new_bauble)

#Removes a bauble of a given type
func despawn_bauble(type_of_bauble):
	var inventory : Array = get("bauble_inventory_" + type_of_bauble)
	var bauble_to_delete = inventory.back()
	if bauble_to_delete != null:
		bauble_to_delete.queue_free()
		inventory.remove_at(inventory.find(bauble_to_delete))

#Checks all the distances for each bauble of a given type
func set_distances(group : String):
	if !is_instance_valid(player):
		player = Global.player
	if is_instance_valid(player):
		for bauble in get("bauble_inventory_" + group):
			if is_instance_valid(bauble):
				var distance = bauble.global_position.distance_to(player.global_position)
				#print("Bauble: " + str(bauble) + " Distance: " + str(distance))
				get("bauble_distances_" + group)[bauble] = distance

#Checks which bauble to throw based on distance from the player
func choose_thrown():
	if !is_instance_valid(player) and is_instance_valid(Global.player):
		player = Global.player
	if is_instance_valid(player):
		set_distances(selected_type)
		var selected_bauble
		var lowest_distance : float = 999999.0
		for bauble in get("bauble_distances_" + selected_type):
			if is_instance_valid(bauble) and bauble.can_throw == true:
				var distance = get("bauble_distances_" + selected_type)[bauble]
				if distance < lowest_distance:
					selected_bauble = bauble
					lowest_distance = distance
		#print(get("bauble_distances_" + selected_type))
		if is_instance_valid(selected_bauble):
			selected_bauble.thrown = true
			selected_bauble = null
