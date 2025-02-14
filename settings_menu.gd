extends Control


@onready var settings_menu: Control = $"."
@onready var pause_menu: Control = $"../PauseMenu"

func _on_back_to_settings_pressed() -> void:
	settings_menu.hide()
	pause_menu.show()
