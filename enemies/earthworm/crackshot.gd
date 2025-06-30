extends Node2D

@onready var sprite = $CharacterBody2D/AnimatedSprite2D

var new_sprite 
var dir = Vector2(1,1)
var speed = 75
var spin = 0
var move = Vector2(0,0)

func _ready():
	if new_sprite is SpriteFrames:
		sprite.sprite_frames = new_sprite
		print("I have a new animatiom :)")
	$CharacterBody2D.velocity = dir * speed 
	$Timer.wait_time = 6
	$Timer.start() 
	#$CharacterBody2D/AnimatedSprite2D.rotation = get_angle_to(Global.player.global_position)
	$CharacterBody2D/AnimatedSprite2D.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$CharacterBody2D.move_and_slide()
	if Engine.time_scale == 1:
		global_position += move*4
	move = Vector2.from_angle(move.angle() + spin)
	
	
func _on_timer_timeout():
	queue_free()


func _on_damage_zone_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.is_in_group("player"):
		
		var ex = preload("res://effects/explosion.tscn").instantiate()
		get_parent().add_child(ex)
		ex.global_position = global_position
		queue_free()
	
	pass # Replace with function body.
func changeAngle(angle):
	move = angle
func spinny(angle):
	spin += angle
	
