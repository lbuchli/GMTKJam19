extends KinematicBody2D

signal input_changed(new_input)

signal screen_entered
signal screen_exited
signal asleep
const INPUTS = ["right", "left", "jump"]

const UP = Vector2(0, -1)

const MOVEMENT_SPEED = 300
const FRICTION = 29
const JUMP_STRENGTH = 800
const GRAVITATION = 50
const INPUT_DELAY = 700
const ENERGY = float(5)

class InputQueueEntry:
	var timestamp : int
	var input : Vector2
	
	func _init(timestamp, input):
		self.timestamp = timestamp
		self.input = input

var velocity = Vector2(0, 0)
var current_energy = ENERGY

var input_queue = []
var current_input = Vector2(0, 0)

var jumped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	# if asleep, do not react
	if current_energy <= 0:
		fall_asleep()
		return
	
	# push new input
	if _has_input_changed(INPUTS) or jumped:
		jumped = Input.is_action_just_pressed("jump")
		
		var new_input = Vector2(
			int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
			int(jumped)
		)
		
		emit_signal("input_changed", new_input)
		
		input_queue.push_back(
			InputQueueEntry.new(
				OS.get_system_time_msecs(),
				new_input
			)
		)
	
	# get old input
	if input_queue.size() > 0:
		if OS.get_system_time_msecs() - input_queue[0].timestamp > INPUT_DELAY:
			current_input = input_queue.pop_front().input
	
	_move(
		current_input, delta
	)

func _move(input, delta):
	# movement
	var jump = -input.y if is_on_floor() else 0
	velocity = move_and_slide(
		Vector2(
			input.x*MOVEMENT_SPEED + velocity.x,
			jump*JUMP_STRENGTH + velocity.y + GRAVITATION
		), UP
	)
	velocity.x /= FRICTION
	
	# energy
	current_energy -= abs(input.x) * delta
	current_energy += jump * 10 * delta
	
	# animation
	if is_on_floor():
		if input.x == 0:
			$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.flip_h = input.x < 0
			$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.flip_h = input.x < 0
		
	if jump == -1:
		$AnimatedSprite.play("jump")

func _has_input_changed(inputs):
	for input in inputs:
		if Input.is_action_just_pressed(input) or Input.is_action_just_released(input):
			return true
	return false

func _on_Visibility_screen_entered():
	emit_signal("screen_entered")


func _on_Visibility_screen_exited():
	emit_signal("screen_exited")
	
func fall_asleep():
	$AnimatedSprite.play("fall_asleep")
	$CollisionShape2D.position.y += 16*4
	yield($AnimatedSprite, "animation_finished")
	$CollisionShape2D.position.y -= 16*4
	emit_signal("asleep")
	current_energy = ENERGY