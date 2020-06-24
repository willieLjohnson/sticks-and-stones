extends KinematicBody

var speed = 7
var acceleration = 20
var gravity = 9.8
var jump = 5

var mouse_sensitivity = 0.05

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

onready var head = $Head

func _ready() -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
