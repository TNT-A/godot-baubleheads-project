extends TextureRect

var game_scene : PackedScene = preload("res://level_manager.tscn")

func _on_button_start_pressed() -> void:
	$FadeToBlack.fade_to_black()
	await $FadeToBlack/AnimationPlayer.animation_finished
	get_tree().change_scene_to_packed(game_scene)

func transition():
	pass
