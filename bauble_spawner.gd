extends Node2D

#Nodes act weird when multiple are in one scene together, so be careful!

var inArea : bool = false
var cost : int = 0 
var type : String = "ruby"

func _ready() -> void:
	choose_self()
	if type == "ruby":
		$AnimatedSprite2D.play("RedIdle")
	if type == "sapphire":
		$AnimatedSprite2D.play("BlueIdle")
	if type == "topaz":
		$AnimatedSprite2D.play("YellowIdle")

func choose_self():
	var rand : int = randi_range(0, 2)
	if rand == 0:
		type = "ruby"
	if rand == 1:
		type = "sapphire"
	if rand == 2:
		type = "topaz"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		spawn_bauble()

func spawn_bauble():
	if Global.gems > cost:
		Global.gems -= cost
		BaubleManager.spawn_bauble(type)
		cost += 1
	set_tutorial_text()

func set_tutorial_text():
	$CanvasLayer/CenterContainer/VBoxContainer/LabelCost.text = "Push E to Spawn a Bauble for " + str(cost) +  " Gems"
	$CanvasLayer/CenterContainer/VBoxContainer/LabelMoney.text = "You Have " + str(Global.gems) +  " Gems"
	if inArea:
		$CanvasLayer.visible = true
	else: 
		$CanvasLayer.visible = false

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		inArea = true
		set_tutorial_text()

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		inArea = false
		set_tutorial_text()
