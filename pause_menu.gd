extends Control

@onready var settings_menu: Control = $"../SettingsMenu"

@onready var main = $"../../"
@onready var pause_menu: Control = $"."


func _on_resume_pressed() -> void:
	main.pauseMenu()


func _on_settings_pressed() -> void:
	settings_menu.show()
	pause_menu.hide()
