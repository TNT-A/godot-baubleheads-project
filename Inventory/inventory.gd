extends Control

@onready var inventorySlots : Array = [
	%InventorySlot,
	%InventorySlot2,
	%InventorySlot3,
	%InventorySlot4,
	%InventorySlot5,
	%InventorySlot6,
	%InventorySlot7,
	%InventorySlot8,
]

@onready var partySlots : Array = [
	%PartySlot,
	%PartySlot2,
	%PartySlot3,
	%PartySlot4,
	%PartySlot5,
	%PartySlot6,
	%PartySlot7,
	%PartySlot8,
	%PartySlot9,
	%PartySlot10,
]

var inventory : Dictionary = {
	"ruby" = 0,
	"topaz" = 0,
	"sapphire" = 0,
	"emerald" = 0,
	"opal" = 0,
	"diamond" = 0,
}

func _ready() -> void:
	SignalBus.item_used.connect(use_item)
	SignalBus.picked_up.connect(recieve_item)
	reset_inventory()
	set_inventory()

func _physics_process(delta: float) -> void:
	organize_party()

func set_inventory():
	for item in inventory:
		if Global.pickup_inventory[item] > 0:
			var item_count = Global.pickup_inventory[item]
			for number in item_count:
				add_item(item)

func reset_inventory():
	for item in inventory:
		inventory[item] = 0

func organize_party():
	for slot in partySlots:
		var global_inventory_slot
		var global_type_in_slot = null
		var slot_index
		slot_index = partySlots.find(slot)
		global_inventory_slot = BaubleManager.bauble_inventory[slot_index]
		if global_inventory_slot is Node:
			global_type_in_slot = global_inventory_slot.type.type
		if slot.held_type != global_type_in_slot:
			SignalBus.update_party_slot.emit(global_type_in_slot, slot_index)

func find_empty_slot():
	var found_slot : Node 
	for slot in inventorySlots:
		if slot.slot_full == false:
			found_slot = slot
			break
		else:
			pass
	return found_slot

func find_slot_with_item(item_type):
	var found_slot
	for slot in inventorySlots:
		if slot.held_type == item_type:
			found_slot = slot
			break
		else:
			found_slot = find_empty_slot()
	return found_slot.slot_number

func use_item(item_resource, slot):
	var item_type = item_resource.type
	inventory[item_type] -=1

func recieve_item(item_resource):
	var target_slot : int
	if item_resource:
		inventory[item_resource.type] += 1
		target_slot = find_slot_with_item(item_resource.type)
		SignalBus.item_added.emit(item_resource, target_slot)

func add_item(string_type):
	var item_to_add = load("res://pickups/pickup_resource/item_" + string_type+ ".tres")
	recieve_item(item_to_add)
