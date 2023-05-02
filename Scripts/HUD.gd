extends Node2D

signal key_spawn

var greenscore = 0
var redscore = 0
var key = false

onready var player = get_node("/root/World/KinematicBody2D")
onready var heart9 = $CanvasLayer/Heart9
onready var heart8 = $CanvasLayer/Heart8
onready var heart7 = $CanvasLayer/Heart7
onready var heart6 = $CanvasLayer/Heart6
onready var heart5 = $CanvasLayer/Heart5
onready var heart4 = $CanvasLayer/Heart4
onready var heart3 = $CanvasLayer/Heart3
onready var heart2 = $CanvasLayer/Heart2
onready var heart1 = $CanvasLayer/Heart1
onready var key_false = $CanvasLayer/key_false
onready var key_true = $CanvasLayer/key_true



func _ready():
	$CanvasLayer/CurrentCounterGreen.text = String(greenscore)
	$CanvasLayer/CurrentCounterRed.text = String(redscore)
	key_true.visible = false


# kontrolerar score och om spelare har nyckel samt skickar signal för nyckelns spawn
func _physics_process(delta: float) -> void:
	if greenscore == 5 and redscore == 6:
		emit_signal("key_spawn")
	_lives()
	if key == true:
		key_true.visible = true
		key_false.visible = false

# uppdaterar score
func _on_GreenDiamond_pickup():
	greenscore = greenscore + 1
	_ready()

# uppdaterar score
func _on_RedDiamond_pickup():
	redscore = redscore + 1
	_ready()

# key true
func _on_Key_pickup():
	key = true

# gömmer sprite för liv
func _lives():
	if player.lives == 8:
		heart9.visible = false
	elif player.lives == 7:
		heart8.visible = false
	elif player.lives == 6:
		heart7.visible = false
	elif player.lives == 5:
		heart6.visible = false
	elif player.lives == 4:
		heart5.visible = false
	elif player.lives == 3:
		heart4.visible = false
	elif player.lives == 2:
		heart3.visible = false
	elif player.lives == 1:
		heart2.visible = false
	elif player.lives == 0:
		heart1.visible = false
