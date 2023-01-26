extends KinematicBody2D
class_name MovableObjekt

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	velocity = move_and_slide(velocity)



func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		var state = body.state
		body.can_push = true
		if body.can_push and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and (state == body.PUSH_ACTIVE):
			print(body.state)
			velocity = body.velocity
			velocity.y = 0
		
		


func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		body.can_push = false
		

