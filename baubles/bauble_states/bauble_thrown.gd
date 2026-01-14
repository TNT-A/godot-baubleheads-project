extends State
class_name BaubleThrown

var pathfinding_controller
var animation_player : AnimationPlayer
var body_detector
var throw_target : Vector2
var throw_ended : bool = false
var damage_active : bool = true
var throw_damage : int = 2
var range : float = 0.4
var bauble_body : CharacterBody2D 

var throw_speed : float = 500
var base_throw_speed : float = 500
var dist

#How throw?
# 1. Click on where you want the bauble to go.
# 2. The bauble will go in that direction and stop if either:
# 	 The bauble gets tossed out of range
# 	 The bauble reaches wherever the mouse landed.

func enter():
	reset()
	bauble_body = get_parent().get_parent().body
	damage_active = true
	throw_target = Vector2(0,0)
	parent_body.can_throw = false
	throw_ended = false
	pathfinding_controller = parent_body.find_child("Pathfinding")
	body_detector = parent_body.find_child("BodyDetector")
	animation_player = pathfinding_controller.host.find_child("AnimationPlayer")
	body_detector.clear_body()
	pathfinding_controller.host.global_position = pathfinding_controller.target_node.global_position
	throw_target = get_global_mouse_position()
	set_speed()
	$ThrowTimer.wait_time = range
	$ThrowTimer.start()
	#animation_player.play("throw")

func set_speed():
	dist = abs(Global.player.global_position.distance_to(throw_target))
	throw_speed = dist / range

func physics_update(delta):
	check_transitions()
	pathfinding_controller.active = false
	throw()
	spin()
	rise()

func throw():
	var direction = (throw_target - player.global_position).normalized()
	pathfinding_controller.host.velocity = direction * throw_speed

func spin():
	$"../../BaubleBody/Sprite2D".rotation += 0.5

func rise():
	var pos = abs(dist/2 - abs($"../../BaubleBody".global_position.distance_to(throw_target) - dist/2)) / dist
	print(pos)
	$"../../BaubleBody/Sprite2D".position.y = pos * -75

func check_collisions():
	if pathfinding_controller.host.is_on_wall() or pathfinding_controller.host.is_on_ceiling():
		end_throw()

func end_throw():
	animation_player.stop()
	animation_player.play("idle")
	pathfinding_controller.host.velocity = Vector2(0,0)
	body_detector.active = false
	parent_body.thrown = false
	throw_ended = true
	reset()

func reset():
	$"../../BaubleBody/Sprite2D".rotation = 0
	$"../../BaubleBody/Sprite2D".position.y = 0

func check_transitions():
	if throw_ended == true:
		#print(body_detector.enemy_found)
		SignalBus.transitioned.emit(self, "Return")

func _on_throw_timer_timeout() -> void:
	end_throw()
