extends State
class_name BaubleIdle

var pathfinding_controller

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = false
	pathfinding_controller.change_target(player) 

func check_transitions():
	if Input.is_action_just_pressed("Player_Ability_2"):
		SignalBus.transitioned.emit(self, "Patrol")
	if pathfinding_controller.at_target == false:
		SignalBus.transitioned.emit(self, "Follow")
