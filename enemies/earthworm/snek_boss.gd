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
	add_child(crackshot.instantiate())
	var a = crackshot.instantiate()
	a.mo = Vector2(0,0)
	add_child(a)
	
	var b = crackshot.instantiate()
	b.mo = Vector2(0,0)
	add_child(b)
	
func crackcircle():
	pass


func _on_timer_timeout():
	attackChoice = randf_range(0,100)
	$Timer.wait_time = randf_range(0.5,1.5)

	$Timer.start()
	attack(attackChoice)
