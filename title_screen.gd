extends TextureRect

var game_scene : PackedScene = preload("res://level_manager.tscn")

func _ready() -> void:
	$FadeToBlack.fade_from_black()
	await $FadeToBlack/AnimationPlayer.animation_finished

func _on_button_start_pressed() -> void:
	$FadeToBlack.fade_to_black()
	await $FadeToBlack/AnimationPlayer.animation_finished
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else: 
		game_scene = load("res://level_manager.tscn")
		get_tree().change_scene_to_packed(game_scene)

func transition():
	pass
