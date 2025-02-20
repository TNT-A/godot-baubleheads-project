extends CenterContainer

enum States {EMPTY, HOVERED, DROPPED, FULL}
var state: States = States.EMPTY

var has_member : bool = false
var item_hovering : bool = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	state_transition()
	state_functions()
	print($Area2D.global_position)

func state_transition():
	if state == States.EMPTY and item_hovering == true:
		state = States.HOVERED
	if state == States.HOVERED and item_hovering == false:
		state = States.EMPTY
	if state == States.HOVERED and item_hovering == true and Input.is_action_just_released("Player_Ability_1"):
		state = States.DROPPED
	if state == States.DROPPED:
		state = States.FULL

func state_functions():
	if state == States.EMPTY:
		$TextureRect.texture = load("res://Inventory/inventory_slot.png")
	if state == States.HOVERED:
		pass
	if state == States.DROPPED:
		pass
	if state == States.FULL:
		$TextureRect.visible = false
		$Area2D.scale *= 0

func item_dropped():
	pass

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	item_hovering = true

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	item_hovering = false

#func _on_area_2d_mouse_entered() -> void:
	#print("Yippee")
#
#func _on_area_2d_mouse_exited() -> void:
	#print("sad D:")
