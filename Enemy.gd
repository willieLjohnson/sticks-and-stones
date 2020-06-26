extends KinematicBody

var health = 200

enum  {
	IDLE,
	ALERT,
	STUNNED
}

var state = IDLE

var target

const TURN_SPEED = 2

onready var raycast = $RayCast
onready var animation_player = $dummymale/AnimationPlayer
onready var eyes = $Eyes

func _ready() -> void:
	pass

func _on_SightRange_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		state = ALERT
		target = body


func _on_SightRange_body_exited(body: Node) -> void:
	state = IDLE

func _process(delta: float) -> void:
	match state:
		IDLE:
			animation_player.play("Idle")
		ALERT:
			animation_player.play("Alert")
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))
		STUNNED:
			animation_player.play("Stunned")
			
	if health <= 0:
		queue_free()
