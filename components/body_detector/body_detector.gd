extends Area2D

@onready var player : Node = Global.player
@onready var parent : Node = get_parent()

@export var active : bool = true

var tracked_body : Node
var enemy_found : bool = false

func lose_enemy():
	if !is_instance_valid(tracked_body):
		enemy_found = false
		tracked_body = null

func clear_body():
	enemy_found = false
	tracked_body = null

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#print(body, ", was just hit")
	if is_instance_valid(body) and active and  body.is_in_group("enemy"):
		tracked_body = body
		enemy_found = true

func _physics_process(delta: float) -> void:
	lose_enemy()

#var in_player : bool = false
#var tracking_enemy : bool = false
#var last_hit_enemy 

#func lose_enemy():
	#if !is_instance_valid(last_hit_enemy):
		#tracking_enemy = false
		#last_hit_enemy = null
#
#func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if body == player:
		#in_player = true
	#if body.is_in_group("enemy"):
		#tracking_enemy = true
		#last_hit_enemy = body
	#if active:
		#parent.inPlayer = in_player
		#if tracking_enemy:
			#parent.current_enemy = last_hit_enemy
#
#func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	#if body == player:
		#in_player = false
	#if active:
		#parent.inPlayer = in_player
