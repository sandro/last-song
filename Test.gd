extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Label.text = "%s" % $AudioStreamPlayer.get_playback_position()
	$Label2.text = "%s" % $AudioStreamPlayer2.get_playback_position()


func _on_Button2_pressed():
	$AudioStreamPlayer2.play(0)


func _on_Button_pressed():
	$AudioStreamPlayer.play(0)
