extends Node2D

@onready var move = Vector2(global_position.x - Global.player.global_position.x, global_position.y - Global.player.global_position.y).normalized()
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = 6
	$Timer.start() 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position -= move*4
	pass


func _on_timer_timeout():
	queue_free()
	pass # Replace with function body.
