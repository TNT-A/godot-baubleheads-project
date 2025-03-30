extends CharacterBody2D

var target : Vector2

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$AnimationPlayer.play("up")
