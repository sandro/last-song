extends Area

signal notePlayed
signal sustained

var colliding = false
var sustaining = false
var currentTime = 0
var sustainStartTime = 0
var sustainEndTime = 0
var sustainTime = 0
var sustainPlayer
onready var streamLength = $AudioStreamPlayer.stream.get_length()
onready var particles = preload("res://Explosion.tscn")

func _ready():
	connect("body_exited", self, "_on_NoteC3_body_exited")

func _process(delta):
	currentTime += delta
	if Input.is_action_just_pressed("click") and colliding:
		print("SUSTAIN", name)
		sustaining = true
		sustainStartTime = currentTime
		setupSustain()
	if Input.is_action_just_released("click") and sustaining:
		print("sustain time", sustainTime)
		sustainEndTime = currentTime
		stopSustain()
		$AudioStreamPlayer.stop()

	if sustaining:
		sustain()
		sustainTime += delta
		
func setupSustain():
	pass
#	sustainPlayer = AudioStreamPlayer.new()
#	sustainPlayer.stream = AudioStreamSample.new()
#	var file = File.new()
#    file.open("res://save_game.dat", File.READ)
#	sustainPlayer.stream.data = $AudioStreamPlayer.stream.get_data()
#	sustainPlayer = $AudioStreamPlayer.duplicate(DUPLICATE_SIGNALS)
#	sustainPlayer.stream.data = $AudioStreamPlayer.stream.get_data()
#	add_child(sustainPlayer)

func stopSustain():
	sustainPlayer && sustainPlayer.stop()
	if sustaining:
		emit_signal("sustained", self, sustainStartTime, sustainEndTime)
	sustaining = false
	
func sustain():
	var currentPosition = $AudioStreamPlayer.get_playback_position()
	if streamLength - currentPosition < streamLength * 0.01:
		$AudioStreamPlayer.play(streamLength * 0.01)
#	print(currentPosition)
#	if !sustainPlayer.playing && streamLength - currentPosition < streamLength * 0.2:
#		prints("start sustain player", streamLength, currentPosition, streamLength - currentPosition)
#		sustainPlayer.play(streamLength*0.2)
#		$AudioStreamPlayer.stop()
#	elif !$AudioStreamPlayer.playing:
#		print("switching to main stream")
#		$AudioStreamPlayer.play(sustainPlayer.get_playback_position())
#		sustainPlayer.stop()

func startReplaySustain():
	sustaining = true
	playYourself()
	
func stopReplaySustain():
	sustaining = false

func playYourself():
	$AudioStreamPlayer.play(0)
	
func stop():
	$AudioStreamPlayer.stop()
	if sustaining:
		sustainEndTime = currentTime
	stopSustain()
	currentTime = 0

func _on_NoteC3_body_entered(body):
	print("body entered", body, body.name)
	if body.name == "Player":
		colliding = true
		playYourself()
		emit_signal("notePlayed", self)
		var explosion = particles.instance()
		var pts = explosion.get_child(0)
		pts.one_shot = true
		pts.emitting = true
		add_child(explosion)

func _on_NoteC3_body_exited(body):
	print("body exit", body.name)
	if body.name == "Player":
		colliding = false
