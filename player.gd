extends RigidBody3D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	linear_velocity.x = 5
	if Input.is_action_pressed("thrust"):
		apply_force(Vector3(0, 30, 0))
