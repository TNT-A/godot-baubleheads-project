extends Marker2D

var mousing : bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Player_Ability_2"):
		mousing = true
	else:
		mousing = false
	if !mousing:
		arrow_move()
	elif mousing:
		mouse_move()

func arrow_move():
	var input : Vector2 = Vector2()
	if Input.is_action_pressed("Move_Up"):
		input.y -=1
	if Input.is_action_pressed("Move_Down"):
		input.y +=1
	if Input.is_action_pressed("Move_Left"):
		input.x -=1
	if Input.is_action_pressed("Move_Right"):
		input.x +=1
	global_position += input*2

func mouse_move():
	position = get_global_mouse_position()
