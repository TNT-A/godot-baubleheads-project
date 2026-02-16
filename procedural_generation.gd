extends Level

var room_count : int = 4
var room_list : Dictionary = {
	"base_room" : preload("res://Maps/test_room.tscn"),
	"big_room" : preload("res://Maps/test_big_room.tscn")
}

var base_room_size = 320

func _ready() -> void:
	generate_floor()

func generate_floor():
	create_base_room()
	extend_by_one("big_room", Vector2(base_room_size, 0), Vector2(0,0))
	#extend_by_one("base_room", Vector2(base_room_size, 0), Vector2(0,0))
	#extend_by_one("base_room", Vector2(0, base_room_size), Vector2(0,0))
	#extend_by_one("base_room", Vector2(base_room_size, base_room_size), Vector2(0,0))
	#extend_by_one("base_room", Vector2(-base_room_size, 0), Vector2(0,0))
	#extend_by_one("base_room", Vector2(0, -base_room_size), Vector2(0,0))
	#extend_by_one("base_room", Vector2(-base_room_size, -base_room_size), Vector2(0,0))
	#extend_by_one("base_room", Vector2(-base_room_size, base_room_size), Vector2(0,0))
	#extend_by_one("base_room", Vector2(base_room_size, -base_room_size), Vector2(0,0))

func create_base_room():
	var base_room = room_list["base_room"].instantiate()
	add_child(base_room)
	#player_spawn_location = base_room.player_spawn_location

#room_type = String for room_list dict 
#extension_dist is basically room size, it's how far away the room will spawn from its og pos
#extension_pos = the position of the top left corner of the room
func extend_by_one(room_type : String, extension_dist : Vector2, extension_pos : Vector2):
	var room = room_list[room_type].instantiate()
	room.global_position.x = extension_pos.x + extension_dist.x
	room.global_position.y = extension_pos.y + extension_dist.y
	add_child(room)
