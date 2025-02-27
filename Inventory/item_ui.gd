extends Control
class_name draggable_object

@export var type : Resource 

@onready var og_scale : Vector2 = $Sprite2D.scale * 2

var target_slot : int = -1
var base_position
var is_mouse_entered : bool = false
var is_at_target : bool = false
var mouse_position : Vector2 
var speed : float = 0.2

enum States {BASE, HOVERED, DRAGGED, RETURN, USED}
var state: States = States.BASE

func _ready() -> void:
	state = States.BASE
	size = Vector2(64,64)
	if type:
		$Sprite2D.texture = type.inventory_sprite

func _physics_process(delta: float) -> void:
	if get_parent().is_in_group("inventory_slot"):
		base_position = get_parent().global_position
	else:
		base_position = Vector2(100,100)
	is_item_at_base()
	state_transition()
	state_functions()

func state_transition():
	if state == States.BASE and is_mouse_entered == true and is_item_at_base() == true:
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
	elif state == States.RETURN and is_item_at_base() == true:
		state = States.BASE

func state_functions():
	mouse_position = get_global_mouse_position()
	if state == States.BASE:
		$Sprite2D.scale = og_scale
		$Area2D/CollisionShape2D.scale = Vector2(1, 1)
		self.global_position = base_position
	if state == States.HOVERED:
		$Sprite2D.scale = og_scale * 1.2 
	if state == States.DRAGGED:
		global_position = mouse_position
		is_item_at_base()
		$Area2D/CollisionShape2D.scale = Vector2(.05, .05)
	if state == States.RETURN:
		$Sprite2D.scale = og_scale
		self.global_position = lerp(self.global_position, base_position, speed)
	if state == States.USED:
		SignalBus.item_used.emit(type, target_slot)
		state = States.BASE

func is_item_at_base():
	var is_at_base : bool = true
	var distance : Vector2 = global_position - base_position
	var max_distance = Vector2(3,3)
	if distance >= max_distance:
		is_at_base = false
	else:
		is_at_base = true
	return is_at_base

func _on_mouse_entered() -> void:
	is_mouse_entered = true

func _on_mouse_exited() -> void:
	is_mouse_entered = false

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("party_slot"):
		var slot_node = area.get_parent()   
		target_slot = slot_node.slot
		is_at_target = true

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area:
		if area.is_in_group("party_slot"):
			target_slot = -1
			is_at_target = false
