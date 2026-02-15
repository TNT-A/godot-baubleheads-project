extends Level

var room_count : int = 4
var room_list : Dictionary = {
	"base_room" : preload("res://Maps/test_room.tscn")
}

func _ready() -> void:
	generate_floor()

func generate_floor():
	create_base_room()

func create_base_room():
	var base_room = room_list["base_room"].instantiate()
	add_child(base_room)
	player_spawn_location = base_room.player_spawn_location
	#base_room.spawn_player()
