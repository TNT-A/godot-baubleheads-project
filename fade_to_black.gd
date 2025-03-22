extends ColorRect



func _ready() -> void:
	SignalBus.fade_to_black.connect(fade_to_black)
	SignalBus.fade_from_black.connect(fade_from_black)
	#await fade_to_black()

func fade_to_black():
	$AnimationPlayer.play("fade_to_black")

func fade_from_black():
	$AnimationPlayer.play("fade_from_black")
