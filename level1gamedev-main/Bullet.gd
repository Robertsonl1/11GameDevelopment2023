extends RigidBody3D

var shoot = false

const DAMAGE = 50
const SPEED = 10

func _ready():
	set_as_top_level(true)

func _physics_process(_delta):
	if shoot:
		apply_impulse(-transform.basis.z, transform.basis.z * SPEED)

func _on_area_3d_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= DAMAGE
		queue_free()
	else:
		queue_free()
