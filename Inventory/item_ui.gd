extends Control
class_name draggable_object

@export var item_type : Resource 

@onready var base_position : Vector2 = get_parent().position

var is_mouse_entered : bool = false
var is_at_base : bool = true
var is_at_target : bool = false
var mouse_position : Vector2 
var speed : float = 0.2

enum States {BASE, HOVERED, DRAGGED, RETURN, USED}
var state: States = States.BASE

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if get_parent().is_in_group("inventory_slot"):
		base_position = get_parent().global_position
	else:
		base_position = Vector2(100,100)
	is_item_at_base()
	state_transition()
	state_functions()
	print(base_position)
	print(get_parent().get_groups())

func state_transition():
	if state == States.BASE and is_mouse_entered == true and is_at_base == true:
		state = States.HOVERED
	elif state == States.HOVERED and is_mouse_entered == false:
		state = States.BASE
	elif state == States.HOVERED and Input.is_action_just_pressed("Player_Ability_1"):
		state = States.DRAGGED
	elif state == States.DRAGGED and Input.is_action_just_released("Player_Ability_1"):
		if is_at_target == false:
			state = States.RETURN
		if is_at_target == true:
			state = States.USED
	elif state == States.RETURN and is_at_base == true:
		state = States.BASE

func state_functions():
	mouse_position = get_global_mouse_position()
	if state == States.BASE:
		$Sprite2D.scale = Vector2(0.517,0.202)
		self.global_position = base_position
	if state == States.HOVERED:
		$Sprite2D.scale = Vector2(0.517,0.202) * 1.2 
	if state == States.DRAGGED:
		self.global_position = mouse_position
		$Area2D/CollisionShape2D.scale = Vector2(.05, .05)
	if state == States.RETURN:
		$Sprite2D.scale = Vector2(0.517,0.202)
		self.global_position = lerp(self.global_position, base_position, speed)
	if state == States.USED:
		$Sprite2D.scale = Vector2(0.1, 0.1)

func is_item_at_base():
	var distance : Vector2 = abs(self.global_position - base_position)
	var max_distance = 3
	if distance <= Vector2(max_distance, max_distance):
		is_at_base = true
	else:
		is_at_base = false

func _on_mouse_entered() -> void:
	is_mouse_entered = true

func _on_mouse_exited() -> void:
	is_mouse_entered = false
