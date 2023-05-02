extends Label


func _ready():
	var time = Globals.time
	var mili = fmod(time, 1) * 1000 
	var secs = fmod(time, 60)
	var mins = fmod(time, 3600) / 60
	
	var time_passed = "%02d : %02d : %02d" %  [mins,secs,mili]
	text = time_passed




