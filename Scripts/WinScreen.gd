extends Node2D
 
const SAVE_FILE_PATH = "user://LivesOfPussInBoots.save"

var time = 0 


func _ready():
	_load_highscore(SAVE_FILE_PATH)
	print(time)
	
	if Globals.time < time:
		time = Globals.time
		Globals.best_time = time
		_save_highscore(SAVE_FILE_PATH)
	else:
		Globals.best_time = time
	
	
	

	

func _on_New_Game_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_Quit_pressed():
	get_tree().quit()


func _load_highscore(FILE_PATH) -> void:
	var save_file = File.new()
	if save_file.file_exists(FILE_PATH):
		save_file.open(FILE_PATH, File.READ)
		time = save_file.get_var()
		save_file.close()

func _save_highscore(FILE_PATH) -> void:
	var save_file = File.new()
	save_file.open(FILE_PATH, File.WRITE)
	save_file.store_var(time)
	save_file.close()
