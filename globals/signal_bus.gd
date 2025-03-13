extends Node

#UI and Inventory
signal picked_up(item_resource)
signal item_added(item_resourse, item_slot)
signal item_used(item_resourse, party_slot)
signal update_party_slot(item_type, party_slot)

#Enemy Thingamajigs
signal change_enemy_health(enemy, change)
