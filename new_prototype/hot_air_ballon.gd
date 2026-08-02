extends RigidBody3D

var up_force = 0.0
var up_force_vel = 0.0

func _ready() -> void:
	gravity_scale = 0.2
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		apply_force(Vector3(0, 8, 0))
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	apply_impulse(Vector3(0, up_force, 0))
	up_force = max(0.0, up_force + up_force_vel * delta)
	if up_force == 0.0:
		up_force_vel = 0.0
	else:
		up_force_vel -= delta * 5.0
	print("up_force_vel: ", up_force_vel, ", up_force:", up_force)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		# apply_impulse(Vector3(0, 2, 0))
		up_force_vel += 1.0
		print("Mouse Click/Unclick at: ", event.position, event.pressed)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		print("Mouse Motion at: ", event.screen_relative)
		# apply_force(Vector3(event.screen_relative.x, 0, event.screen_relative.y) * 1.0)
		apply_impulse(Vector3(event.screen_relative.x, 0, event.screen_relative.y) * 0.01)
