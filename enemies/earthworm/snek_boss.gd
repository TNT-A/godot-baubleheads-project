extends Node2D
#dive + return
#fireball, crackshot
#bite
var nearbyBaubles : Array = []
var attackChoice: int 
var circleable = true
var crackshot: PackedScene = preload("res://enemies/earthworm/crackshot.tscn")
func _ready():
	$Timer.wait_time = randf_range(0.5,1.5)
	$Timer.start()

func _physics_process(delta: float) -> void:
	if Engine.time_scale == 1:
		pass

func attack(ac):
	#if attackChoice <= 50:
	#	crack()
	# elif ac < 20:
		# bite()
	# elif ac < 50:
	# 	crack()
	#if (nearbyBaubles.size() > 0 or attackChoice < 10) and circleable:
	#	crackcircle()
	if true:
		spinnycircle()
	else:
		crack()
		
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
	var rand = randf_range(0,20)
	for i in range(12):
		var a = crackshot.instantiate()
		a.changeAngle(Vector2.from_angle(i*PI/6 + rand).normalized())
		add_child(a)
	circleable = false
	$Timer2.wait_time = 10
	$Timer2.start()
func spinnycircle():
	var rand = randf_range(0,20)
	for i in range(12):
		
		var a = crackshot.instantiate()
		a.changeAngle(Vector2.from_angle(i*PI/6 + rand).normalized())
		a.spinny(.05) # make this really high for funny maelstrom
		add_child(a)
		
	

func _on_timer_timeout():
	attackChoice = randf_range(0,100)
	$Timer.wait_time = randf_range(.5,1.5)
	
	$Timer.start()
	attack(attackChoice)

func _on_area_2d_body_entered(body):
	if body.is_in_group("bauble"):
		nearbyBaubles.append(body)
	
func _on_area_2d_body_exited(body):
	if body.is_in_group("bauble"):
		var index = nearbyBaubles.find(body)
		nearbyBaubles.remove_at(index)
	pass # Replace with function body.

	

func _on_timer_2_timeout():
	circleable = true
