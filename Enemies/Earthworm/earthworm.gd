extends CharacterBody2D

var player : Node = Global.player



#func deal_damage():
	#
	#pass

func _on_damage_zone_body_entered(body: Node2D) -> void:
	body = player
	#deal_damage()
	pass # Replace with function body.
