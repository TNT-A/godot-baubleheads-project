extends Node2D
#dive + return
#fireball, crackshot
#bite

var attackChoice: int 
var crackshot: PackedScene = preload("res://enemies/earthworm/crackshot.tscn")
func _ready():
	$Timer.wait_time = randf_range(0.5,1.5)
	$Timer.start()
	
func _physics_process(delta: float) -> void:
	if Engine.time_scale == 1:
		pass
	
	
	
func attack(ac):
	if ac <= 100:
		crack()
	elif ac < 20:
		bite()
	elif ac < 50:
		crack()
	elif ac <= 100:
		crackcircle()
		
func dig():
	pass
func bite():
	pass
func crack():
	var vto = Vector2(Global.player.global_position.x, Global.player.global_position.y)
	
	var a = crackshot.instantiate()
	$AnimatedSprite2D.play("crackx3")
	await get_tree().create_timer(.15).timeout
	
	a.changeAngle(vto.normalized())
	add_child(a)
	
	var b = crackshot.instantiate()
	b.changeAngle(Vector2.from_angle(vto.angle() + PI/8).normalized())
	add_child(b)
	
	var c = crackshot.instantiate()
	c.changeAngle(Vector2.from_angle(vto.angle() - PI/8).normalized())
	add_child(c)
func crackcircle():
	pass


func _on_timer_timeout():
	attackChoice = randf_range(0,100)
	$Timer.wait_time = randf_range(.5,1.5)

	$Timer.start()
	attack(attackChoice)
