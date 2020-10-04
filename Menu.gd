extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const VOLUMES = [-36, -24, -18, -12, -3]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Quit_pressed():
	print("quit pressed")
	get_tree().quit()


func _on_Start_Over_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hide()
	get_tree().change_scene("res://World.tscn")
	get_tree().paused = false


func _on_Resume_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	hide()
	get_tree().paused = false


func _on_HSlider_value_changed(value):
	var level = VOLUMES[value]
	print(level)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), level)
