extends Area2D

var exit_open : bool = true
@onready var player = Global.player

func transition_scenes():
	SignalBus.emit_signal("scene_transition")

#func check_if_open():
	#pass

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		if exit_open == true:
			transition_scenes()
		else:
			print("L bozo")
