extends Control

@export var stack_count : int = 0
@export var slot_number : int = 0
@export var current_item : Resource

@onready var empty_slot_texture : Texture = preload("res://Inventory/inventory_slot.png")
@onready var item_scene : PackedScene = preload("res://Inventory/item_ui_test.tscn")

var held_item :  Node 
var held_type : String = "blank"
var slot_full : bool = false

func _ready() -> void:
	SignalBus.item_added.connect(add_item)
	SignalBus.item_used.connect(use_item)
	if current_item is Resource:
		create_new_stack(current_item)

func _physics_process(delta: float) -> void:
	update_text()

func add_item(item_resource, slot):
	if slot_number == slot:
		if stack_count == 0:
			create_new_stack(item_resource)
		else:
			add_to_stack()

func create_new_stack(item_resource): 
	var new_item = item_scene.instantiate()
	held_type = item_resource.type
	new_item.type = item_resource.path
	add_child(new_item)
	held_item = new_item
	slot_full =  true
	add_to_stack()

func add_to_stack():
	stack_count += 1

func use_item(item_resource, party_slot):
	if item_resource.type == held_type:
		stack_count -= 1
		find_empty_slot()

func find_empty_slot():
	if stack_count == 0:
		remove_item()

func remove_item():
	$TextureRect.texture = empty_slot_texture
	held_item.queue_free()
	held_item = null
	held_type = "blank"
	slot_full = false

func update_text():
	$Label.text = str(stack_count)
