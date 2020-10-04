extends KinematicBody

var gravity = Vector3.DOWN * 1  # strength of gravity

var speed = 8  # movement speed
var jump_speed = 6  # jump strength
var spin = 0.1  # rotation speed
var velocity = Vector3()
var jump = false
var origin = Vector3()
var overallTime = 0
var runTime = 0
var playback = []
var currentPlaybackIndex = 0
var loops = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	updateHudLoops()
	origin = translation
	for c in get_parent().get_children():
		if c.is_in_group("note_container"):
			for n in c.get_children():
				if n.is_in_group("note"):
					n.connect("notePlayed", self, "_on_note_played")
					n.connect("sustained", self, "_on_sustained")
					
func reset():
	translation.y = origin.y
	runTime = 0
	loops += 1
	updateHudLoops()
	for n in playback:
		n.reset()
		
func updateHudLoops():
	$"../HUD/Loops".text = "LOOPS: %s" % loops

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if event.relative.x > 0:
			rotate_y(-lerp(0, spin, event.relative.x/10))
		elif event.relative.x < 0:
			rotate_y(-lerp(0, spin, event.relative.x/10))

func get_input():
	var vy = velocity.y
	velocity = Vector3()
	if Input.is_action_pressed("move_forward"):
		velocity += -transform.basis.z * speed
#		print("FORWARD", transform.basis.z)
	if Input.is_action_pressed("move_back"):
		velocity += transform.basis.z * speed
#		print("BACK")
	if Input.is_action_pressed("strafe_right"):
		velocity += transform.basis.x * speed
	if Input.is_action_pressed("strafe_left"):
		velocity += -transform.basis.x * speed
	velocity.y = vy
	jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true

func _process(delta):
	overallTime += delta
	runTime += delta
	handlePlayback()
	if Input.is_action_just_pressed("escape"):
		get_tree().paused = true
		$"../CanvasLayer/Menu".show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
#	velocity += gravity * delta
	velocity.y = -5 # -500 * delta
	get_input()
#	if jump and is_on_floor():
#		velocity.y = jump_speed
	velocity = move_and_slide(velocity, Vector3.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Floor":
			print("hit floo")
			reset()
		else:
			prints("HIT", collision.collider.name)
			
func handlePlayback():
	for i in range(playback.size()):
		var replayItem = playback[i]
		replayItem.checkPlay(runTime, loops)

func _on_note_played(node):
	printt("note played", runTime, playback)
	playback.append(ReplayItem.new(runTime, node, loops))
	
func _on_sustained(node, startTime, endTime):
	for x in playback:
		if x.node == node:
			x.addSustain(startTime, endTime)

func _on_Spatial_tree_entered():
	prints("tree entered", 1) # Replace with function body.

class ReplayItem:
	var replayAt
	var node
	var played = false
	var sustainStarted = false
	var loopOrigin = 0
	var sustainStartTime
	var sustainEndTime
	
	func _init(replayAt, node, loopOrigin):
		self.replayAt = replayAt
		self.node = node
		self.loopOrigin = loopOrigin
		
	func checkPlay(t, currentLoop):
		if t > replayAt and !played and currentLoop != loopOrigin:
			node.playYourself()
			played = true
		if sustainStartTime:
			if t >= sustainStartTime and !sustainStarted:
				node.startReplaySustain()
				sustainStarted = true
			if t >= sustainEndTime and sustainStarted:
				node.stopReplaySustain()
	
	func play():
		node.playYourself()
		
	func reset():
		played = false
		sustainStarted = false
		node.stop()
		
	func addSustain(startTime, endTime):
		print("add sustain", startTime, endTime)
		sustainStartTime = startTime
		sustainEndTime = endTime
