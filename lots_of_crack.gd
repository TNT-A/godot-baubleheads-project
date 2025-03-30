extends CharacterBody2D

var target : Vector2

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("up")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "up":
		$FallTimer.start()
