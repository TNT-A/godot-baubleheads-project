extends CharacterBody2D

@onready var player_body: CharacterBody2D = $"."

func _on_damage_zone_body_entered(body: Node2D) -> void:
	body = player_body


@export var bullet_scene : PackedScene

func get_input():
	if Input.is_action_just_pressed("Testing"):
		shoot()
		
func shoot():
	var b = bullet_scene.instantiate()
	owner.add_child(b)
	b.transform = $Mouth.global_transform
