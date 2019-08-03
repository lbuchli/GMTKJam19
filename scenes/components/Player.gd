extends KinematicBody2D

const UP = Vector2(0, -1)

const MOVEMENT_SPEED = 400
const FRICTION = 29
const JUMP_STRENGTH = 1000
const GRAVITATION = 50

var velocity = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	move(
		Vector2(
			int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")),
			int(Input.is_action_just_pressed("jump")) if is_on_floor() else 0
		), delta
	)

func move(input, delta):
	velocity = move_and_slide(
		Vector2(
			input.x*MOVEMENT_SPEED + velocity.x,
			(-input.y*JUMP_STRENGTH) + velocity.y + GRAVITATION
		), UP
	)
	velocity.x /= FRICTION