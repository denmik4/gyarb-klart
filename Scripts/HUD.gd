extends Node2D

signal key_spawn

var greenscore = 0
var redscore = 0
var key = false

func _ready():
	$CanvasLayer/CurrentCounterGreen.text = String(greenscore)
	$CanvasLayer/CurrentCounterRed.text = String(redscore)
	
func _physics_process(delta: float) -> void:
	if greenscore == 4 and redscore == 5:
		emit_signal("key_spawn")

func _on_GreenDiamond_pickup():
	greenscore = greenscore + 1
	_ready()


func _on_RedDiamond_pickup():
	redscore = redscore + 1
	_ready()


func _on_Key_pickup():
	key = true
