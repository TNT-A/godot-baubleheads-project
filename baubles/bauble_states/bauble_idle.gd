extends State
class_name BaubleIdle

var pathfinding_controller
var adapt_target

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")
	adapt_target = parent_body.find_child("AdaptTarget")

func physics_update(delta):
	if is_instance_valid(player):
		adapt_target.global_position = player.global_position
	check_transitions()
	pathfinding_controller.active = false

func check_transitions():
	if Input.is_action_just_pressed("Player_Ability_2"):
		SignalBus.transitioned.emit(self, "Patrol")
	if pathfinding_controller.at_target == false:
		SignalBus.transitioned.emit(self, "Follow")
	if parent_body.thrown:
		SignalBus.transitioned.emit(self, "Thrown")
