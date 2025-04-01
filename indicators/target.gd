extends AnimatedSprite2D

var target : Vector2 = Vector2(0, 0)

func _ready() -> void:
	SignalBus.target_hit.connect(despawn)
	global_position = target
	play("grow")

func _on_animation_finished() -> void:
	if animation == "grow":
		play("flash")

func despawn(target):
	if target == self:
		queue_free()
