extends Area2D

@onready var timer: Timer = $Timer
@onready var node = get_node("player")

@export var damage_dealt : int = 1
