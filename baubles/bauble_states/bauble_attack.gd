extends State
class_name BaubleAttack

var pathfinding_controller
var attack_started : bool = false
var attack_finished : bool = false
var body_detector

func enter():
	parent_body.can_throw = false
	attack_started = false
	attack_finished = false
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")
	pathfinding_controller.host.velocity = Vector2(0,0)

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = false
	pathfinding_controller.host.move_and_slide()
	if !attack_started:
		attack_enemy()

func attack_enemy():
	attack_started = true
	var direction : Vector2 
	var max_enemy_distance : Vector2 = Vector2(50,50)
	var enemy_position : Vector2 = body_detector.tracked_body.global_position
	var my_position = pathfinding_controller.host.global_position
	var target_position : Vector2 = enemy_position + (enemy_position - my_position)
	var distance : Vector2 
	direction = (target_position - my_position).normalized()
	pathfinding_controller.host.velocity = (400 * direction)
	await get_tree().create_timer(.2).timeout
	print("attack_done")
	pathfinding_controller.host.velocity = Vector2(0,0)
	await get_tree().create_timer(.2).timeout
	attack_finished = true

func check_transitions():
	if body_detector.tracked_body == null:
		SignalBus.transitioned.emit(self, "Return")
	if attack_finished:
		SignalBus.transitioned.emit(self, "Targeting")
