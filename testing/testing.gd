extends Node2D

@onready var player_body: CharacterBody2D = $PlayerBody
@onready var pause_menu: Control = %PauseMenu
@onready var settings_menu: Control = %SettingsMenu

var paused = false

func _ready():
	pause_menu.hide()
	settings_menu.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
