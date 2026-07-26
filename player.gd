extends RigidBody3D

const stabilizer_y_pid_params = preload("res://pid_params.tres")
@onready var pid_controller = PidController.new(stabilizer_y_pid_params)

var time_acc = 0.0
var thrust_ramp = 0.0
var flip = false

func _ready() -> void:
	update_active_cylinder()
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	%RayCast3D.position = position

	time_acc += delta

	if Input.is_action_just_released("thrust"):
		flip = !flip
		update_active_cylinder()

	var dist = 10.0
	if %RayCast3D.is_colliding():
		var hit_point = %RayCast3D.get_collision_point()
		dist = %RayCast3D.global_position.distance_to(hit_point)

	var thrust = 0
	var pid_output = pid_controller.calculate(1, dist, delta)
	#print(pid_output, " ", dist)
	thrust = max(0, 30 * pid_output)
	apply_force(Vector3(0, thrust, 0))

	var particles = %ParticlesRight if flip else %ParticlesLeft
	if Input.is_action_pressed("thrust") and dist > 0.0:
		thrust_ramp = min(1, thrust_ramp + delta * 4)
		var dir = particles.global_basis.y
		apply_force(global_transform.basis * 30 * dir * thrust_ramp)
		particles.amount_ratio = thrust_ramp
	else:
		thrust_ramp = max(0, thrust_ramp - delta * 5)
		%ParticlesLeft.amount_ratio = 0
		%ParticlesRight.amount_ratio = 0


func update_active_cylinder():
	%CSGCylinderLeft.material_override = null
	%CSGCylinderRight.material_override = null
	var active_cylinder = %CSGCylinderRight if flip else %CSGCylinderLeft
	active_cylinder.material_override = preload("res://material_highlighted.tres")
