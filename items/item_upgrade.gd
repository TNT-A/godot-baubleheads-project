extends Node2D

@export var item_resource : Resource 

@onready var player : Node = Global.player

var playerInRange : bool = false

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interact") and playerInRange:
		take_item()

func take_item():
	
	queue_free()

func random_item():
	pass

func _on_item_radius_body_entered(body: Node2D) -> void:
	#print(body, " entered ", player)
	if body == player:
		playerInRange = true
		print("player entered")

func _on_item_radius_body_exited(body: Node2D) -> void:
	#print(body, " exited ", player)
	if body == player:
		playerInRange = false
		print("player left")
