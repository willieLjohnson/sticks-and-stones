extends MeshInstance


func _ready() -> void:
	pass

func shoot():
	if Input.is_action_just_pressed("fire"):
		print("Gun2 fired")
