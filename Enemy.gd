extends KinematicBody

var health = 200

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
