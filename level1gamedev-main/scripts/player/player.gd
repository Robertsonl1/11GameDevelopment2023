extends CharacterBody3D

var speed = 10
var horizontal_acceleration = 6
var air_acceleration = 1
var normal_acceleration = 6
var gravity = 20
var jump = 10
var full_contact = false

var damage = 50

var mouse_sensitivity = 0.03

var direction = Vector3()
var horizontal_velocity = Vector3()
var movement = Vector3()
var gravity_vec = Vector3()

@onready var head = $Head
@onready var ground_check = $GroundCheck
@onready var aimcast = $Head/Camera3D/Aimcast
@onready var muzzle = $Head/Gun/Muzzle
@onready var bullet = preload("res://scenes/player/bullet.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(_delta):
	
	if is_on_ceiling():
		gravity_vec = Vector3.ZERO
	
	if ground_check.is_colliding():
		full_contact = true
	else:
		full_contact = false
	
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * _delta
		horizontal_acceleration = air_acceleration
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		horizontal_acceleration = normal_acceleration
	else:
		gravity_vec = -get_floor_normal()
		horizontal_acceleration = normal_acceleration
		
	if Input.is_action_just_pressed("jump") and (is_on_floor() or ground_check.is_colliding()):
		gravity_vec = Vector3.UP * jump
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	horizontal_velocity = horizontal_velocity.lerp(direction * speed, horizontal_acceleration * _delta)
	movement.z = horizontal_velocity.z + gravity_vec.z
	movement.x = horizontal_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	if Input.is_action_just_pressed("fire"):
		if aimcast.is_colliding():
			var b = bullet.instantiate()
			muzzle.add_child(b)
			b.look_at(aimcast.get_collision_point(), Vector3.UP)
			b.shoot = true
	
	velocity = movement
	
	move_and_slide()
