extends State
class_name BaubleFollow

var pathfinding_controller

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = true
	pathfinding_controller.speed = 200

func check_transitions():
	if Input.is_action_just_pressed("Player_Ability_2"):
		SignalBus.transitioned.emit(self, "Patrol")
	if pathfinding_controller.at_target == true:
		SignalBus.transitioned.emit(self, "Idle")
