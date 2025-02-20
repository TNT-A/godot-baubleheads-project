extends Area2D


var speed = 100

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta

func _on_bullet_body_entered(body: Node2D) -> void:
	queue_free()
