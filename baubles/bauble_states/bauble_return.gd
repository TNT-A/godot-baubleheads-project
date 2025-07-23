extends State
class_name BaubleReturn

var pathfinding_controller
var adapt_target

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")
	adapt_target = parent_body.find_child("AdaptTarget")

func physics_update(delta):
	if is_instance_valid(player):
		adapt_target.global_position = player.global_position
	check_transitions()
	pathfinding_controller.active = true
	pathfinding_controller.speed = 250

func check_transitions():
	if pathfinding_controller.at_target == true:
		SignalBus.transitioned.emit(self, "Idle")
