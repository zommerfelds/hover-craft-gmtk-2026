extends RigidBody3D

const stabilizer_y_pid_params = preload("res://pid_params.tres")
@onready var pid_controller = PidController.new(stabilizer_y_pid_params)

var time_acc = 0.0
var thrust_ramp = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	%RayCast3D.position = position

	time_acc += delta
	rotation_degrees.z = sin(time_acc * 5) * 30

	# linear_velocity.x = 3

	var dist = 10.0
	if %RayCast3D.is_colliding():
		var hit_point = %RayCast3D.get_collision_point()
		dist = %RayCast3D.global_position.distance_to(hit_point)

	var thrust = 0

	var pid_output = pid_controller.calculate(1, dist, delta)
	print(pid_output, " ", dist)
	thrust = max(0, 30 * pid_output)

	if Input.is_action_pressed("thrust") and dist > 0.0:
		#var thrust = 200 * max(0, 1-dist) + 5
		#apply_force(Vector3(0, thrust, 0))
		# thrust = max(thrust, 30)
		thrust_ramp = min(1, thrust_ramp + delta * 4)
		apply_force(global_transform.basis * Vector3(0, 30, 0) * thrust_ramp)
	else:

		thrust_ramp = max(0, thrust_ramp - delta * 5)

	apply_force(Vector3(0, thrust, 0))
