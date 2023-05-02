extends Area2D

const RIGHT = Vector2.RIGHT
export(int) var SPEED: int = 1000
onready var sprite = $Sprite



# ger fysiska egenskaper till sicklen, rotation och rörelse
func _physics_process(delta):
	var movement = RIGHT.rotated(rotation) * SPEED * delta
	global_position += movement
	sprite.rotation_degrees += 7.5

# tar bort sickle
func destroy():
	queue_free()
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
# ändrar antal liv om player blev träffat av sickle
func _on_Sickle_body_entered(body):
	if body.is_in_group("Player"):
		body.lives -= 1
		if body.lives == 0:
			get_tree().change_scene("res://Scenes/DeadScreen.tscn")
			
		destroy()

func _on_VisibilityNotifier2D_screen_entered():
	pass

