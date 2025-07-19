extends State
class_name BaubleFollow

var pathfinding_controller

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = true
	#pathfinding_controller.change_target(player) 
	#pathfinding_controller.speed = parent_body.stats.speed

func check_transitions():
	if pathfinding_controller.at_target == true:
		#print("switching to idle")
		SignalBus.transitioned.emit(self, "Idle")
