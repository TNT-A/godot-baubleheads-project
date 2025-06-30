extends Area2D

@onready var parent = get_parent()

var nearby_baubles : Array = []
var attacking_baubles : Array = []
var count_attacking : int = 0

func _physics_process(delta: float) -> void:
	check_attacking_baubles()
	parent.count_attacking = count_attacking
	print(count_attacking)

func check_attacking_baubles():
	for bauble in nearby_baubles:
		var index = nearby_baubles.find(bauble)
		if !is_instance_valid(nearby_baubles[index]):
			nearby_baubles.remove_at(index)
	for bauble in attacking_baubles:
		var index = attacking_baubles.find(bauble)
		if !is_instance_valid(attacking_baubles[index]):
			attacking_baubles.remove_at(index)
	for bauble in nearby_baubles:
		if !attacking_baubles.has(bauble):
			if bauble.state == bauble.States.ATTACK or bauble.state == bauble.States.TARGETING: 
				attacking_baubles.append(bauble)
		elif attacking_baubles.has(bauble):
			if bauble.state != bauble.States.ATTACK and bauble.state != bauble.States.TARGETING: 
				var index = attacking_baubles.find(bauble)
				attacking_baubles.remove_at(index)
	count_attacking = attacking_baubles.size()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		nearby_baubles.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("bauble"):
		var index = nearby_baubles.find(body)
		nearby_baubles.remove_at(index)
