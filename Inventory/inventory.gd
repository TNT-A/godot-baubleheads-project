extends Control

var inventory : Dictionary

func _ready() -> void:
	SignalBus.picked_up.connect(recieve_item)

func _physics_process(delta: float) -> void:
	position

func recieve_item(item):
	print("Come and give me a hug :smiling_imp:")
	pass
