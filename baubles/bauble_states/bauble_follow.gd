extends State
class_name BaubleFollow

var pathfinding_controller
var adapt_target

func enter():
	parent_body.can_throw = true
	pathfinding_controller = parent_body.find_child("Pathfinding")
	adapt_target = parent_body.find_child("AdaptTarget")

func physics_update(delta):
	if is_instance_valid(player):
		adapt_target.global_position = player.global_position
	check_transitions()
	pathfinding_controller.active = true
	pathfinding_controller.speed = 200

func check_transitions():
	if Input.is_action_just_pressed("Player_Ability_2"):
		SignalBus.transitioned.emit(self, "Patrol")
	if pathfinding_controller.at_target == true:
		SignalBus.transitioned.emit(self, "Idle")
	if parent_body.thrown:
		#print("I'm thrown")
		SignalBus.transitioned.emit(self, "Thrown")
