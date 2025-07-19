extends State
class_name BaubleIdle

var pathfinding_controller

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")
	#print(pathfinding_controller)

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = false
	pathfinding_controller.change_target(player) 

func check_transitions():
	if pathfinding_controller.at_target == false:
		#print("switching to follow")
		SignalBus.transitioned.emit(self, "Follow")
