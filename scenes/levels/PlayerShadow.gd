extends KinematicBody2D

var velocity = Vector2(0, 0)

const UP = Vector2(0, -1)

const MOVEMENT_SPEED = 400
const FRICTION = 29
const JUMP_STRENGTH = 1000
const GRAVITATION = 50
const INPUT_DELAY = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var current_input = Vector2(0, 0)

func _physics_process(delta):
	_move(current_input, delta)

func _move(input, delta):
	velocity = move_and_slide(
		Vector2(
			input.x*MOVEMENT_SPEED + velocity.x,
			(-input.y*JUMP_STRENGTH if is_on_floor() else 0) + velocity.y + GRAVITATION
		), UP
	)
	velocity.x /= FRICTION

func _on_Player_input_changed(new_input):
	current_input = new_input
