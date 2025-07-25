extends Area2D

var exit_open : bool = true
@onready var player = Global.player

func transition_scenes():
	SignalBus.emit_signal("scene_transition")

func _on_body_entered(body: Node2D) -> void:
	print("trying to leave, exit open: ", exit_open)
	if body == player:
		if exit_open == true:
			transition_scenes()
			print("transitioning")
		else:
			print("L bozo")
