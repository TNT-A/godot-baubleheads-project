extends Level
class_name Room

@onready var player_scene : PackedScene = preload("res://player/player.tscn")
@onready var player_spawn_position = $PlayerSpawn.global_position

#Assume 10x10 = 1x1
var room_width : int = 1
var room_height : int = 1

var doorways : Dictionary = {
	"top1" = false,
	"top2" = true,
	"top3" = false,
	
	"bot1" = false,
	"bot2" = true,
	"bot3" = false,
	
	"left1" = false,
	"left2" = true,
	"left3" = false,
	
	"right1" = false,
	"right2" = true,
	"right3" = false,
}

func _ready() -> void:
	#spawn_player()
	pass

func spawn_player():
	var new_player = player_scene.instantiate()
	self.add_child(new_player)
	new_player.global_position = player_spawn_position
