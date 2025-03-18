extends Node

var player

var player_stats : Dictionary = {
	max_health = 5,
	health = 5,
	speed = 200,
}

var pickup_inventory : Dictionary = {
	"ruby" = 0,
	"topaz" = 0,
	"sapphire" = 0,
	"emerald" = 0,
	"opal" = 0,
	"diamond" = 0,
}

func _ready() -> void:
	pass 

func register_player(in_player):
	player = in_player
