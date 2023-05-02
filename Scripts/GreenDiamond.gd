extends Area2D

signal pickup

onready var player = get_node("/root/World/KinematicBody2D")

func _process(delta: float) -> void:
	pass


# kontrollerar om gubben plockar diamant 
func _on_GreenDiamond_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("pickup")
		body.pick_up_green()
		queue_free()
