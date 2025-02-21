extends CharacterBody2D

@export var item_type : Resource

var item : String

#func _ready() -> void:
	#item = item_type.type

func _physics_process(delta: float) -> void:
	pass

func pickup():
	SignalBus.picked_up.emit("ruby")
	queue_free()

func _on_pickup_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("player") :
		pickup() 
