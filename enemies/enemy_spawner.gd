extends Node2D

@export var enemy_type : Resource
@export var spawn_time : float = 5.0
@export var spawns_left : int = 5

var enemy_scene : PackedScene = preload("res://enemies/earthworm/wiggly_earthworm.tscn")

var can_spawn : bool = true

func _ready() -> void:
	SignalBus.all_enemies_killed.connect(stop_spawn)
	$SpawnTimer.wait_time = spawn_time
	if enemy_type:
		enemy_scene = enemy_type.path
	else:
		enemy_scene = preload("res://enemies/earthworm/wiggly_earthworm.tscn")
	#spawn_enemy()

func _on_spawn_timer_timeout() -> void:
	if can_spawn:
		$AnimationPlayer.play("spawn_in")

func spawn_enemy():
	var new_enemy : Node = enemy_scene.instantiate()
	new_enemy.starting_position = global_position
	if Global.player:
		new_enemy.target = Global.player
		new_enemy.has_target = true
	get_parent().add_child.call_deferred(new_enemy)
	SignalBus.emit_signal("enemy_added", new_enemy)
	#print("it spawned")
	spawns_left -= 1
	if spawns_left <= 0:
		stop_spawn()

func stop_spawn():
	can_spawn = false

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	spawn_enemy()
