extends Node2D

#It's like some kind of perfect puppeteer...
@export var body : Node

var move_types: Array = [
	"player",
	"pathfind_towards",
	"pathfind_away"
	]

func _physics_process(delta: float) -> void:
	body.move_and_slide()

#body.velocity
