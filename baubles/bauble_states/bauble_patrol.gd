extends State
class_name BaublePatrol

var pathfinding_controller

func enter():
	print(self)
	pathfinding_controller = parent_body.find_child("Pathfinding")

func physics_update(delta):
	pathfinding_controller.active = true
	#pathfinding_controller.change_target(player) 
	pathfinding_controller.speed = parent_body.stats.speed

func check_transitions():
	if pathfinding_controller.at_target == true:
		SignalBus.transitioned.emit(self, "Idle")
	if Input.is_action_pressed("Player_Ability_2") and parent_body.accept_input:
		SignalBus.transitioned.emit(self, "Patrol")
	if Input.is_action_pressed("Player_Ability_1") and pathfinding_controller.at_target and parent_body.accept_input and parent_body.can_hold and !BaubleManager.throwing:
		SignalBus.transitioned.emit(self, "Held")
