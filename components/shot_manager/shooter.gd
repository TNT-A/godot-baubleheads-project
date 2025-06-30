extends Node2D

@onready var parent_node = get_parent()  
@onready var projectile_field 
#This ^ will be added once projectile field is up and running

#The evalues you can change in editor to create an attack
@export_group("Shot 1 Properties")
@export var shot1_sprite : SpriteFrames
@export var shot1_projectile : AvailableProjectiles
@export var shot1_type : ShotTypes
@export var shot1_num : int = 1

@export_group("Shot 2 Properties")
@export var shot2_sprite : SpriteList
@export var shot2_projectile : AvailableProjectiles
@export var shot2_type : ShotTypes
@export var shot2_num : int = 1

@export_group("Shot 3 Properties")
@export var shot3_sprite : SpriteList
@export var shot3_projectile : AvailableProjectiles
@export var shot3_type : ShotTypes
@export var shot3_num : int = 1

@export_group("Shot 4 Properties")
@export var shot4_sprite : SpriteList
@export var shot4_projectile : AvailableProjectiles
@export var shot4_type : ShotTypes
@export var shot4_num : int = 1

@export_group("Shot 5 Properties")
@export var shot5_sprite : SpriteList
@export var shot5_projectile : AvailableProjectiles
@export var shot5_type : ShotTypes
@export var shot5_num : int = 1

#Maximum different types of shots you can store in your loadout, currently each enemy can only have a total of 5 different shooting patterns
var max_shots

#Where the data for the enemy's shooting patterns are stored
var shot_loadout : Array = [
	[],
	[],
	[],
	[],
	[],
]

var projectileList : Dictionary = {
	"straight" = preload("res://enemies/earthworm/crackshot.tscn")
}

#Lists for the @export vars to function, and for the enums to inherit from
var sprites: Array = [
	"crack" 
	]
var projectiles: Array = [
	"straight" 
	]
var shot_types: Array = [
	"reg",
	"spread", 
]

#Enums used in @export
enum SpriteList {crack}
enum AvailableProjectiles {straight}
enum ShotTypes {reg, spread}

func _ready() -> void:
	max_shots = len(shot_loadout)
	set_shots()
	shoot(0, Vector2(1,0))

#Sets the enemy's shot_loadout based on the values of their @export vars
func set_shots():
	var shot_count = len(shot_loadout)
	for i in shot_count:
		i = i+1
		var shot_sprite = get("shot"+str(i)+"_sprite") #Texture of Shot
		var projectile = get("shot"+str(i)+"_projectile") #Scene + Behavior of Shot
		var shot_type = get("shot"+str(i)+"_type") #Formation/Behavior of Shot Firing (ex: single shot, triple shot, spread shot, etc)
		var shot_num = get("shot"+str(i)+"_num") #Number of Times Shot is Fired
		projectile = projectiles[projectile]
		shot_type = shot_types[shot_type]
		shot_loadout[i-1].append(shot_sprite)
		shot_loadout[i-1].append(projectile)
		shot_loadout[i-1].append(shot_type)
		shot_loadout[i-1].append(shot_num)
	print(shot_loadout[0])

#Bassic logic for instanciating a new bullet
func create_shot(sprite, scene, count, angle):
	var new_shot = scene.instantiate()
	if parent_node.is_in_group("enemy"):
		new_shot.global_position = parent_node.global_position
		new_shot.move = (Global.player.global_position - global_position).normalized()
	else:
		new_shot.global_position = Vector2(50,50)
		new_shot.move = angle
	new_shot.new_sprite = sprite
	add_child(new_shot)

#The actual function that will take you @export vars and build the shot based on the values given, then creates it
func shoot(shot_num, angle):
	if shot_num >= max_shots:
		shot_num = max_shots
	var current_shot = shot_loadout[shot_num]
	var shot_sprite = current_shot[0]
	var shot_scene = projectileList[current_shot[1]]
	var shot_form = current_shot[2]
	var shot_count = current_shot[3]
	#print(shot_sprite, " ", shot_scene," ", shot_form," ", shot_count)
	var shot_callable = Callable(self, shot_form)
	shot_callable.call(shot_sprite, shot_scene, shot_count, angle)

#Logic for making a regular shot
func reg(sprite, scene, count, angle):
	create_shot(sprite, scene, count, angle)

#Logic for making a triple shot
func spread(sprite, scene, count, angle):
	create_shot(sprite, scene, count, angle)
	create_shot(sprite, scene, count, (Vector2.from_angle(angle.angle() + PI/8).normalized()))
	create_shot(sprite, scene, count, (Vector2.from_angle(angle.angle() - PI/8).normalized()))
