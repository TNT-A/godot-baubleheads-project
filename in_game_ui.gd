extends CanvasLayer

@onready var pause_menu: Control = %PauseMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var inventory_menu : Control = %Inventory

var paused = false
var inventory = false

func _ready():
	SignalBus.scene_transition.connect(change_scene)
	SignalBus.set_health_bar.connect(set_health_bar)
	SignalBus.resume_game.connect(pauseMenu)
	pause_menu.hide()
	settings_menu.hide()
	inventory_menu.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pauseMenu()
	if Input.is_action_just_pressed("Inventory"):
		inventoryMenu()

func set_health_bar(max_health, health) -> void:
	%HealthBar.max_value = max_health
	%HealthBar.value = health

func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused

func settingsMenu():
	pass

func inventoryMenu():
	if inventory:
		inventory_menu.hide()
		Engine.time_scale = 1
	else:
		inventory_menu.show()
		Engine.time_scale = 1
	inventory = !inventory

func change_scene():
	print('ooga booga')
	pass
