extends State
class_name BaubleTargeting

var pathfinding_controller
var body_detector
var attack_time : float = .5
var attack_ready : bool = false

func enter():
	parent_body.can_throw = false
	attack_ready = false
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")
	$AttackTimer.wait_time = attack_time
	$AttackTimer.start()

func physics_update(delta):
	body_detector.active = true
	if body_detector.enemy_found:
		get_parent().get_parent().find_child("AdaptTarget").global_position = body_detector.tracked_body.global_position
	check_transitions()
	pathfinding_controller.active = true
	pathfinding_controller.speed = 200

func _on_attack_timer_timeout() -> void:
	attack_ready = true

func check_transitions():
	if Input.is_action_just_pressed("Crackhead_Call") or !body_detector.enemy_found:
		SignalBus.transitioned.emit(self, "Return")
	if attack_ready == true:
		SignalBus.transitioned.emit(self, "Attack")
