extends KinematicBody

var health = 200

enum  {
	IDLE,
	ALERT,
	STUNNED
}

var state = IDLE

onready var raycast = $RayCast
onready var animation_player = $dummymale/AnimationPlayer

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if raycast.is_colliding() and raycast.get_collider().is_in_group("Player"):
		state = ALERT
	elif Input.is_action_pressed("fire"):
		state = STUNNED
	else:
		state = IDLE
		
	match state:
		IDLE:
			animation_player.play("Idle")
		ALERT:
			animation_player.play("Alert")
		STUNNED:
			animation_player.play("Stunned")
			
	if health <= 0:
		queue_free()
