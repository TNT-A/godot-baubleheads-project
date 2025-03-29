extends Node2D

@onready var move = Vector2(global_position.x - Global.player.global_position.x, global_position.y - Global.player.global_position.y).normalized()
# Called when the node enters the scene tree for the first time.

func _ready():
	$Timer.wait_time = 6
	$Timer.start() 
	$AnimatedSprite2D.rotation = get_angle_to(Global.player.global_position)
	$AnimatedSprite2D.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.time_scale == 1:
		global_position -= move*4

func _on_timer_timeout():
	queue_free()
