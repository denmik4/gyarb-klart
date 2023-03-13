extends Node2D


export var MainGameScene : PackedScene



func _on_Button_button_up():
	get_tree().change_scene(MainGameScene.resource_path)
	

