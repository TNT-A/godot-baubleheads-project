extends Node2D

@export var none_limit : int = 40
@export var ruby_limit : int = 60
@export var sapphire_limit : int = 80
@export var topaz_limit : int = 100

var pickup_scene : PackedScene = preload("res://pickups/gemstone_pickup.tscn")

var drop_chart : Dictionary = {
	"none" : 25,
	"ruby" : 50,
	"sapphire" : 75,
	"topaz" : 100}

func _ready() -> void:
	set_drop_chart()

func set_drop_chart():
	drop_chart.none = none_limit
	drop_chart.ruby = ruby_limit
	drop_chart.sapphire = sapphire_limit
	drop_chart.topaz = topaz_limit
	#print(drop_chart)

func drop_item():
	var drop_chance : int = randi_range(0, 100)
	if drop_chance < drop_chart["none"]:
		#print("none")
		pass
	elif drop_chart["none"] < drop_chance and drop_chance <= drop_chart["ruby"]:
		create_pickup("ruby")
	elif drop_chart["ruby"] < drop_chance and drop_chance <= drop_chart["sapphire"]:
		create_pickup("sapphire")
	elif drop_chart["sapphire"] < drop_chance and drop_chance <= drop_chart["topaz"]:
		create_pickup("topaz")
	#print("I'm dropping my pickups rn")

func create_pickup(pickup):
	var new_pickup = pickup_scene.instantiate()
	new_pickup.item_resource = load("res://pickups/pickup_resource/item_" + pickup + ".tres")
	get_parent().get_parent().add_child(new_pickup)
	new_pickup.global_position = global_position
