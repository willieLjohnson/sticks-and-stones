extends KinematicBody

var speed
var default_move_speed = 7
var sprint_move_speed = 14
var crouch_move_speed = 3
var crouch_speed = 20
var acceleration = 20
var gravity = 9.8
var jump = 5
var jump_num = 0
var blink_dist = 7


var default_height = 1.5
var crouch_height = 0.5

var mouse_sensitivity = 0.07

var sprinting = false
var grappling = false
var hook_point_get = false

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()
var hook_point = Vector3()

var damage = 100

var wall_normal
var can_wallrun = false

var current_weapon = 1

onready var head = $Head
onready var gun_1 = $Head/Hand/Gun
onready var gun_2 = $Head/Hand/Gun2
onready var gun_3 = $Head/Hand/Gun3
onready var pcap = $CollisionShape
onready var bonker = $HeadBonker
onready var sprint_timer = $SprintTimer
onready var wall_run_timer = $WallRunTimer
onready var aim_cast = $Head/Camera/AimCast
onready var grapple_cast = $Head/Camera/GrappleCast
onready var muzzle = gun_1.get_node("Muzzle")
onready var bullet = preload("res://Bullet.tscn")


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func weapon_select():
	if Input.is_action_just_pressed("weapon_1"):
		current_weapon = 1
	elif Input.is_action_just_pressed("weapon_2"):
		current_weapon = 2
	elif Input.is_action_just_pressed("weapon_3"):
		current_weapon = 3
	
	match(current_weapon):
		1:
			gun_1.visible = true
			gun_2.visible = false
			gun_3.visible = false
			muzzle = gun_1.get_node("Muzzle")
		2:
			gun_1.visible = false
			gun_2.visible = true
			gun_3.visible = false
			muzzle = gun_2.get_node("Muzzle")
		3:
			gun_1.visible = false
			gun_2.visible = false
			gun_3.visible = true
			muzzle = gun_3.get_node("Muzzle")
		
func grapple():
	if Input.is_action_just_pressed("grapple"):
		if grapple_cast.is_colliding():
			if not grappling:
				grappling = true
	if grappling:
		fall.y = 0
		if not hook_point_get:
			hook_point = grapple_cast.get_collision_point() + Vector3(0, 2.25, 0)
			hook_point_get = true
		if hook_point.distance_to(transform.origin) > 1:
			if hook_point_get:
				transform.origin = lerp(transform.origin, hook_point, 0.05)
		else:
			grappling = false
			hook_point_get = false
	if bonker.is_colliding():
		grappling = false
		hook_point = null
		hook_point_get = false
		global_translate(Vector3(0, -1, 0))

func wall_run():
	if can_wallrun:
		if Input.is_action_pressed("jump"):
			if Input.is_action_pressed("move_forward"):
				if is_on_wall():
					wall_normal = get_slide_collision(0)
					yield(get_tree().create_timer(0.2), "timeout")
					fall.y = 0
					direction = -wall_normal.normal * speed
				
func _physics_process(delta: float) -> void:	
	var head_bonked = false
	speed = default_move_speed
	
	direction = Vector3()
	
	move_and_slide(fall, Vector3.UP, true)
	

	if bonker.is_colliding():
		head_bonked = true
		
	if not is_on_floor():
		fall.y -= gravity * delta
	else:
		jump_num = 0
		can_wallrun = false
	
	grapple()
	wall_run()
	weapon_select()
		
	if Input.is_action_just_pressed("jump"):
		if jump_num == 0 and is_on_floor():
			fall.y = jump
			jump_num = 1
			can_wallrun = true
			wall_run_timer.start()
		elif jump_num == 1 and not is_on_floor():
			fall.y = jump
			jump_num = 2
		
	if head_bonked:
		fall.y = -2
		

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
		
	if Input.is_action_just_pressed("fire"):
		if aim_cast.is_colliding():
			var bullet_instance = bullet.instance()
			muzzle.add_child(bullet_instance)
			bullet_instance.look_at(aim_cast.get_collision_point(), Vector3.UP)
			bullet_instance.shoot = true

	if Input.is_action_pressed("crouch"):
		pcap.shape.height -= crouch_speed * delta
		speed = crouch_move_speed
	elif not head_bonked:
		pcap.shape.height += crouch_speed * delta
	
	pcap.shape.height = clamp(pcap.shape.height, crouch_height, default_height)
	
	
	if Input.is_action_just_pressed("ability"):
		sprinting = !sprinting
		if sprinting:
			sprint_timer.start()
	
	if sprinting: speed = sprint_move_speed
		
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z

	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

		
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
		
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x 
				
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)



func _on_SprintTimer_timeout() -> void:
	sprinting = false


func _on_WallRunTimer_timeout() -> void:
	can_wallrun = false
