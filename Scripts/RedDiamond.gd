extends Area2D

signal pickup

onready var player = get_node("/root/World/KinematicBody2D")

func _process(delta: float) -> void:
	pass


# kontrollerar om gubben plockar diamant 
func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		emit_signal("pickup")
		body.pick_up_red()
		queue_free()
			
		
