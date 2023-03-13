extends KinematicBody2D

onready var animationplayer = $AnimationPlayer
var has_key = false

func _ready():
	pass 


func _on_Key_pickup():
	has_key = true

func open_chest():
	animationplayer.play("OpenChest")


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") and has_key == true:
			open_chest()
			yield(get_tree().create_timer(2), "timeout")
			print("DU VANN!!!!!")
