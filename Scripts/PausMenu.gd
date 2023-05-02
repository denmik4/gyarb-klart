extends Control

var is_paused = false setget set_is_paused

# döljer canvaslayer vid start
func _ready() -> void:
	$CanvasLayer.visible = false

# hanterar pause knappen genom att byta paus status och visar eller döljer canvaslayer
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		self.is_paused = !is_paused
		$CanvasLayer.visible = !$CanvasLayer.visible

# uppdaterar paus status
func set_is_paused(value):
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	

# starar spelet igen
func _on_Resume_pressed() -> void:
	self.is_paused = false
	$CanvasLayer.visible = !$CanvasLayer.visible
	
# stänger ner spelet
func _on_Quit_pressed() -> void:
	get_tree().quit()
