extends Area2D


var speed = 100

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

<<<<<<< Updated upstream
func _on_bullet_body_entered(body: Node2D) -> void:
	queue_free()
=======
func destroy():
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_Bullet_body_entered(body):
	if body.is_in_group("player"):
		destroy()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass
>>>>>>> Stashed changes
