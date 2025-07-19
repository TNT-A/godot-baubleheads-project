extends State
class_name BaublePatrol

var pathfinding_controller
var body_detector
var searching : bool = false
var leave : bool = false
var found_enemy : bool = false
var target_enemy : Node

func enter():
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = true
	body_detector.active = true
	pathfinding_controller.speed = 250
	if pathfinding_controller.at_target == true and searching == false:
		search()
	#May not want this, but useful for now
	#if !Input.is_action_pressed("Player_Ability_2"):
		#get_parent().get_parent().find_child("AdaptTarget").position = get_parent().get_parent().find_child("BaubleBody").position

func search():
	print("I'm searching baby")
	searching = true
	$Timer.start()

func check_transitions():
	if Input.is_action_just_pressed("Crackhead_Call"):
		SignalBus.transitioned.emit(self, "Return")
	if leave == true:
		SignalBus.transitioned.emit(self, "Idle")

func _on_timer_timeout() -> void:
	leave = true
	print("I'm done!")
