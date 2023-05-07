extends CharacterBody3D


var speed
var acceleration
var defualt_speed = 5
var sprint_speed = 8
var camera_smoothness = 7.5
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 6

var sprinting = false

var sensitivity = Global.sensitivity

var direction = Vector3()
var fall = Vector3()

var camera_input : Vector2
var rotation_velocity : Vector2

@onready var head = $Head
@onready var ground_check = $GroundCheck

@export var start = false
@export var current_camera = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
	

func _physics_process(delta):
	if start == true:
		play(delta)
	if current_camera == true:
		$Head/Camera.current = true
	else:
		$Head/Camera.current = false
	

func play(delta):
	speed = defualt_speed
	direction = Vector3()
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		acceleration = air_acceleration
	elif is_on_floor() and ground_check.is_colliding():
		acceleration = normal_acceleration
	else:
		acceleration = normal_acceleration
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_just_pressed("sprint") and not sprinting:
		sprinting = true
	elif Input.is_action_just_pressed("sprint") and sprinting:
		sprinting = false
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump
	
	if sprinting:
		speed = sprint_speed
	
	camera_rotation(delta)
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		camera_input = event.relative
	

func camera_rotation(delta):
	# Controller
	var axis_vector = Vector2.ZERO
	axis_vector.y = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	axis_vector.x = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if InputEventJoypadMotion:
		rotate_y(deg_to_rad(-axis_vector.y) * sensitivity * 6)
		head.rotate_x(deg_to_rad(-axis_vector.x) * sensitivity * 6)
	
	# Mouse
	rotate_y(deg_to_rad(-rotation_velocity.x * sensitivity / 10))
	head.rotate_x(deg_to_rad(-rotation_velocity.y * sensitivity / 10))
	
	rotation_velocity = rotation_velocity.lerp(camera_input * sensitivity, camera_smoothness * delta)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	camera_input = Vector2.ZERO
	
