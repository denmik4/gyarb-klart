extends KinematicBody2D
class_name MovableObjekt

var direction_x = "RIGHT"
var velocity := Vector2.ZERO
var direction := Vector2.ZERO
var player = null
var bug_fix = Vector2(1, 0)

func _physics_process(delta: float) -> void:
	if player:
		if player.can_push and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")) and player.state == 8:
			if player.direction.x == 1: 
				velocity = player.velocity
				velocity.y = 0
				move_and_slide(velocity)
			if player.direction.x == -1:
				velocity = player.velocity
				velocity.y = 0
				move_and_slide(velocity)



func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player = body
		body.can_push = true
		if body.can_push and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			velocity = body.velocity
			velocity.y = 0
		
		


func _on_Area2D_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player = null
		body.can_push = false
		

