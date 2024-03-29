extends Control

var _start_time : int

var animation_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_start_time = OS.get_system_time_msecs()

func _input(event):
	if animation_finished and event.is_pressed():
		get_tree().change_scene("res://scenes/levels/Level.tscn")
	

func _on_Start_Button_pressed():
	$StartMenu/Button.disabled = true
	$AnimationPlayer.play("Storytransition")
	yield($AnimationPlayer, "animation_finished")
	animation_finished = true