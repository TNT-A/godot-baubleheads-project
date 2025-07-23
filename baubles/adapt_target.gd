extends Marker2D

@onready var player = Global.player
var mousing : bool = false
var stored_position : Vector2

func _physics_process(delta: float) -> void:
	#if !player:
		#if Input.is_action_pressed("Player_Ability_2"):
			#mousing = true
		#else:
			#mousing = false
		#if !mousing:
			#arrow_move()
			#stored_position = position
		#elif mousing:
			#mouse_move()
	pass

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
