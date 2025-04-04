extends Node

var player

var player_stats : Dictionary = {
	max_health = 5,
	health = 5,
	speed = 200,
}

var base_player_stats : Dictionary = {
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

var base_pickup_inventory : Dictionary = {
	"ruby" = 0,
	"topaz" = 0,
	"sapphire" = 0,
	"emerald" = 0,
	"opal" = 0,
	"diamond" = 0,
}

var upgrades : Dictionary = {
	#Player Multipliers
	"speedMult" = false,
	"throwCooldownMult" = false,
	
	# Bauble Multipliers and Stats
	"damageMult" = false,
	"throwDamageMult" = false,
	"attackSpeedMult" = false,
	"statusChanceMult" = false,
	"statIncreaseMult" = false,
	
	#Passive Upgrades
	"passiveHeal" = false,
	"dropChanceUp" = false,
	"xpBoost" = false,
	
	#New Components
	"baubleExplosion" = false,
	"baubleChain" = false,
	"baubleHoming" = false,
}

func _ready() -> void:
	pass 

func register_player(in_player):
	player = in_player
