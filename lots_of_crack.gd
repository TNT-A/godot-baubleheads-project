extends CharacterBody2D

@onready var player : Node = Global.player

var explosion_scene : PackedScene = preload("res://effects/explosion.tscn")
var target_scene : PackedScene = preload("res://indicators/target.tscn")

var target : Vector2 = Vector2(200, 200)

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("up")

func spawn_explosion():
	var new_explosion = explosion_scene.instantiate()
	new_explosion.global_position = target
	new_explosion.target = target
	get_parent().add_child(new_explosion)

var new_target = target_scene.instantiate()
func create_target():
	new_target.global_position = target
	new_target.target = target
	get_parent().add_child(new_target)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "up":
		$FallTimer.start()
		create_target()
	if anim_name == "Fall":
		spawn_explosion()
		SignalBus.emit_signal("target_hit", new_target)
		queue_free()

func _on_fall_timer_timeout() -> void:
	global_position = target
	$AnimationPlayer.play("Fall")
