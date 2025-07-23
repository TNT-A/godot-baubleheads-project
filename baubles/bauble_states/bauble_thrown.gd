extends State
class_name BaubleThrown

var pathfinding_controller
var animation_player : AnimationPlayer
var body_detector
var throw_target : Vector2
var throw_started : bool = false
var throw_ended : bool = false

func enter():
	parent_body.can_throw = false
	throw_started = false
	throw_ended = false
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")
	animation_player = pathfinding_controller.host.find_child("AnimationPlayer")
	throw_target = get_global_mouse_position()
	body_detector.clear_body()

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = false
	body_detector.active = true
	if !throw_started:
		throw()

func throw():
	throw_started = true
	var direction = (throw_target - global_position).normalized()
	pathfinding_controller.host.velocity = direction * 600
	animation_player.play("throw")

func check_collisions():
	if pathfinding_controller.host.is_on_wall() or pathfinding_controller.host.is_on_ceiling():
		print("Hit Wall")
		end_throw()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "throw":
		print("anim done")
		end_throw()

func end_throw():
	animation_player.stop()
	animation_player.play("idle")
	pathfinding_controller.host.velocity = Vector2(0,0)
	body_detector.active = false
	parent_body.thrown = false
	throw_ended = true

func check_transitions():
	if throw_ended == true:
		if body_detector.enemy_found and body_detector.tracked_body.is_in_group("enemy"):
			SignalBus.transitioned.emit(self, "Targeting")
		else:
			SignalBus.transitioned.emit(self, "Return")
