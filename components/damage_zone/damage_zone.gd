extends Area2D
class_name DamageZone

@export var hurts_player : bool = false
@export var hurts_enemy : bool = false
@export var hurts_bauble : bool = false

@export var is_fire : bool = false
@export var is_ice : bool = false
@export var is_electric : bool = false

func _ready() -> void:
	if hurts_player:
		add_to_group("hurts_player")
	if hurts_enemy:
		add_to_group("hurts_enemy")
	if hurts_bauble:
		add_to_group("hurts_bauble")

@onready var timer: Timer = $Timer
# @onready var node = get_node("player") do we need this?

@export var damage_dealt : int = 1
