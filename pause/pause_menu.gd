extends Control

<<<<<<< Updated upstream:pause/pause_menu.gd
@onready var pause_menu: Control = %PauseMenu
@onready var settings_menu: Control = %SettingsMenu

@onready var main = $"../../"
=======
@onready var settings_menu: Control = $"../SettingsMenu"
@onready var pause_menu: Control = $"."
@onready var main = $"../../"


>>>>>>> Stashed changes:pause_menu.gd

func _on_resume_pressed() -> void:
	main.pauseMenu()

func _on_settings_pressed() -> void:
	settings_menu.show()
	pause_menu.hide()
