extends Node

#Inventory UI
signal inventory_opened
signal picked_up(item_resource)
signal item_added(item_resourse, item_slot)
signal item_used(item_resourse, party_slot)
signal update_party_slot(item_type, party_slot)

#Health UI
signal set_health_bar(max_health, health)

#Pause and Settings UI
signal resume_game
signal settings_opened

#Fade to Black
signal fade_to_black
signal fade_from_black

#Enemy Thingamajigs
signal change_enemy_health(enemy, change)
signal enemy_dead(enemy)
signal enemy_added(enemy)

#Moving Scenese
signal scene_transition

#target destruction
signal target_hit(target_indicator)

#level control
signal all_enemies_killed

#player commands
signal player_died
