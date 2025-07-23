extends Node2D
class_name State

@onready var parent_body = get_parent().get_parent()
@onready var player = Global.player

func enter():
	pass

func exit():
	pass

func update(_delta: float):
	pass

func physics_update(_delta: float):
	pass
