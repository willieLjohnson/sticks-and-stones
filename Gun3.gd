extends MeshInstance

onready var bullet = preload("res://Bullet.tscn")
onready var muzzle = $Muzzle

func _ready() -> void:
	pass

func shoot(aim_cast):
	if Input.is_action_just_pressed("fire"):
		if aim_cast.is_colliding():
			var bullet_instance = bullet.instance()
			bullet_instance.damage = 300
			bullet_instance.mass = 10
			bullet_instance.scale = Vector3(4,4,4)
			muzzle.add_child(bullet_instance)
			bullet_instance.look_at(aim_cast.get_collision_point(), Vector3.UP)
			bullet_instance.shoot = true
