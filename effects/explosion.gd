extends AnimatedSprite2D

var target : Vector2 = Vector2(0, 0)

func _ready() -> void:
	global_position = target
	play("default")

func _on_animation_finished() -> void:
	queue_free()
