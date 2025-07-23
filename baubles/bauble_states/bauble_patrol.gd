extends State
class_name BaublePatrol

var pathfinding_controller
var body_detector
var searching : bool = false
var leave : bool = false
var found_enemy : bool = false
var target_enemy : Node
var adapt_target

func enter():
	leave = false
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")
	adapt_target = parent_body.find_child("AdaptTarget")
	body_detector.clear_body()

func physics_update(delta):
	if Input.is_action_pressed("Player_Ability_2"):
		adapt_target.global_position = get_global_mouse_position()
	check_transitions()
	pathfinding_controller.active = true
	body_detector.active = true
	pathfinding_controller.speed = 250
	search()

func search():
	if pathfinding_controller.at_target == true:
		pathfinding_controller.active = false
		searching = true
		print("we're at target, ", pathfinding_controller.target_vector_position, ", ", self.global_position)
		if $Timer.is_stopped() and !leave:
			$Timer.start()
	else: 
		pathfinding_controller.active = true
		$Timer.stop()

func _on_timer_timeout() -> void:
	body_detector.active = false
	leave = true

func check_transitions():
	if Input.is_action_just_pressed("Crackhead_Call"):
		SignalBus.transitioned.emit(self, "Return")
	if leave == true:
		SignalBus.transitioned.emit(self, "Idle")
	if body_detector.enemy_found and !Input.is_action_pressed("Player_Ability_2"):
		SignalBus.transitioned.emit(self, "Targeting")
