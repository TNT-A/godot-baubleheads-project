extends Camera2D

var max_dist : float = 100
var follow_speed : float = 1
var following : bool = true

func _physics_process(delta: float) -> void:
	follow()
	#if position.distance_to(Vector2(0,0)) >= 50:
		#following = false
	#elif position.distance_to(Vector2(0,0)) <= 40:
		#following = true
		
	#if !following:
		#follow_speed = lerp(follow_speed, 0.0, 0.2)
	#else:
		#follow_speed = lerp(follow_speed, 1.0, 0.5)
		
		#position = position.lerp(Vector2(0,0), 0.02)

func follow():
	var mouse_pos = get_global_mouse_position()
	
	var target : Vector2 = Vector2(0, 0)
	target = (mouse_pos - global_position).normalized() * max_dist
	
	if mouse_pos.distance_to(global_position) >= max_dist:
		position = position.lerp(target, 0.02)
	else:
		position = position.lerp(Vector2(0, 0), 0.02)
	print(position, " & ", position.distance_to(Vector2(0,0)))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		zoom *= 1.2
	if event.is_action_pressed("ui_down"):
		zoom /= 1.2
