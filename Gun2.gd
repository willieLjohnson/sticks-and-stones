extends MeshInstance

onready var bullet = preload("res://Bullet.tscn")
onready var muzzle = $Muzzle

var can_shoot = true
var auto_shoot_speed = 0.05

func _ready() -> void:
	pass

func shoot(aim_cast):
	if Input.is_action_pressed("fire") and can_shoot:
		if aim_cast.is_colliding():
			var bullet_instance = bullet.instance()
			bullet_instance.damage = 10
			bullet_instance.speed = 5
			muzzle.add_child(bullet_instance)
			bullet_instance.look_at(aim_cast.get_collision_point(), Vector3.UP)
			bullet_instance.shoot = true
			$AutoShootTimer.start()
			can_shoot = false

func _on_AutoShootTimer_timeout() -> void:
	can_shoot = true
	$AutoShootTimer.wait_time = auto_shoot_speed
