extends KinematicBody2D
class_name MovableObjekt

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO


signal push
signal idle

func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity)



func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		velocity = body.velocity
		body.connect("push", body, "_on_MovableObjekt_push")
		emit_signal("push")
		


func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		velocity = Vector2.ZERO
		body.disconnect("push", body, "_on_MovableObjekt_push")
		
		

