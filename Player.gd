extends KinematicBody

var speed
var default_move_speed = 7
var crouch_move_speed = 3
var crouch_speed = 20
var acceleration = 20
var gravity = 9.8
var jump = 5
var jump_num = 0
var blink_dist = 7

var default_height = 1.5
var crouch_height = 0.5

var mouse_sensitivity = 0.05

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

onready var head = $Head
onready var pcap = $CollisionShape

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _process(delta: float) -> void:
	speed = default_move_speed
	
	direction = Vector3()
		
	if not is_on_floor():
		fall.y -= gravity * delta
	else:
		jump_num = 0
		
	if Input.is_action_just_pressed("jump"):
		if jump_num == 0 and is_on_floor():
			fall.y = jump
			jump_num = 1
		elif jump_num == 1 and not is_on_floor():
			fall.y = jump
			jump_num = 2
		
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
	if Input.is_action_pressed("crouch"):
		pcap.shape.height -= crouch_speed * delta
		speed = crouch_move_speed
	else:
		pcap.shape.height += crouch_speed * delta
	
	pcap.shape.height = clamp(pcap.shape.height, crouch_height, default_height)
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
		if Input.is_action_just_pressed("ability"):
			 translate(Vector3(0, 0, -blink_dist))
		
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
		if Input.is_action_just_pressed("ability"):
			 translate(Vector3(0, 0, blink_dist))
		
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
		if Input.is_action_just_pressed("ability"):
			 translate(Vector3(-blink_dist, 0, 0))
		
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x 
		if Input.is_action_just_pressed("ability"):
			 translate(Vector3(blink_dist, 0, 0))
				
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall, Vector3.UP, true)
