extends Area2D

signal pickup

onready var player = get_node("/root/World/KinematicBody2D")

onready var key_sprite = $KeySprite
onready var collision_shape = $CollisionShape2D

func _ready():
	key_sprite.visible = false
	collision_shape.disabled = true


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("pickup")
		queue_free()


func _on_HUD_key_spawn():
	key_sprite.visible = true
	collision_shape.disabled = false
