extends CharacterBody2D

@export var item_resource : Resource

func _ready() -> void:
	if item_resource:
		$Sprite2D.texture = item_resource.pickup_sprite

func pickup():
	SignalBus.picked_up.emit(item_resource)
	queue_free()

func _on_pickup_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("player") :
		pickup() 
