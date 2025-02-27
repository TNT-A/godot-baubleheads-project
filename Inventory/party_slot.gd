extends CenterContainer

@export var slot : int = 0
@export var member_info : Resource
@export var held_type = null

var member : Node
var temp_member : Node
var has_member : bool = false
var item_hovering : bool = false

enum States {EMPTY, HOVERED, DROPPED, FULL}
var state: States = States.EMPTY

func _ready() -> void:
	SignalBus.update_party_slot.connect(update_slot)

func _physics_process(delta: float) -> void:
	state_transition()
	state_functions()

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
		pass
		#$TextureRect.texture = load("res://Inventory/inventory_slot.png")
	if state == States.HOVERED:
		pass
	if state == States.DROPPED:
		pass
	if state == States.FULL:
		pass

func update_slot(item_type, party_slot):
	if item_type is String and party_slot == slot:
		$TextureRect.texture = load("res://Inventory/partySprites/party_slot_"+item_type+".png")
		held_type = item_type
	if item_type == null:
		$TextureRect.texture = load("res://Inventory/inventory_slot.png")
		held_type = null

func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("Item"):
		item_hovering = true

func _on_area_2d_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area is Node:
		if area.is_in_group("Item"):
			item_hovering = false

#func _on_area_2d_mouse_entered() -> void:
	#print("Yippee")
#
#func _on_area_2d_mouse_exited() -> void:
	#print("sad D:")
