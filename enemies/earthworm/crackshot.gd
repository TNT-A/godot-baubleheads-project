extends Node2D


var move = Vector2(0,0)
# Called when the node enters the scene tree for the first time.

func _ready():
	$Timer.wait_time = 6
	$Timer.start() 
	$AnimatedSprite2D.rotation = get_angle_to(Global.player.global_position)
	$AnimatedSprite2D.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if Engine.time_scale == 1:
		global_position += move*4

func _on_timer_timeout():
	queue_free()


func _on_damage_zone_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("player"):
		
		var ex = preload("res://effects/explosion.tscn").instantiate()
		get_parent().add_child(ex)
		ex.global_position = global_position
		queue_free()
	
	pass # Replace with function body.
func changeAngle(angle):
	move = angle
	
