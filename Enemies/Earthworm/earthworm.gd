extends Node2D

@onready var player_body: Node2D = $"."

func _on_damage_zone_body_entered(body: Node2D) -> void:
	body = player_body

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var BULLET : PackedScene = null
var target: Node2D = null
@onready var earthworm: CharacterBody2D = $CharacterBody2D
@onready var raycast: RayCast2D = $CharacterBody2D/RayCast2D
@onready var timer: Timer = $CharacterBody2D/RayCast2D/ReloadTimer

func _ready():
	await(get_tree())
	target = find_target()

func _physics_process(delta: float) -> void:
	if target != null:
		var angle_to_target: float = global_position.direction_to(target.global_position).angle()
		raycast.global_rotation = angle_to_target
		
		if raycast.is_colliding() and raycast.get_collider().is_in_group("player"):
			earthworm.rotation = angle_to_target
			if timer.is_stopped():
				shoot()


func shoot():
	
	raycast.enabled = false
	if BULLET: 
		var bullet: Node2D = BULLET.instance()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		bullet.global_rotation = raycast.global_rotation
	timer.start()

func find_target():
	var new_target: Node2D = null
	if get_tree().has_group("player"):
		new_target = get_tree().get_nodes_in_group("player")[0]
	return new_target

func _on_reload_timer_timeout() -> void:
	raycast.enabled = true
