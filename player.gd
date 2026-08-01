extends RigidBody3D

const pid_params = preload("res://pid_params.tres")
@onready var pid_controller_bottom = PidController.new(pid_params)
@onready var pid_controller_top = PidController.new(pid_params)
@onready var pid_controller_left = PidController.new(pid_params)
@onready var pid_controller_right = PidController.new(pid_params)

var time_acc = 0.0
var thrust_ramp = 0.0
var flip = false
var ray_casts_bottom = []
var ray_casts_top = []
var ray_casts_right = []
var ray_casts_left = []

func _ready() -> void:
	update_active_cylinder()

	for ray_cast in %RayCastsBottom.get_children():
		ray_casts_bottom.append({"obj": ray_cast, "offset": ray_cast.position - position})
	for ray_cast in %RayCastsTop.get_children():
		ray_casts_top.append({"obj": ray_cast, "offset": ray_cast.position - position})
	for ray_cast in %RayCastsRight.get_children():
		ray_casts_right.append({"obj": ray_cast, "offset": ray_cast.position - position})
	for ray_cast in %RayCastsLeft.get_children():
		ray_casts_left.append({"obj": ray_cast, "offset": ray_cast.position - position})


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	time_acc += delta

	if Input.is_action_just_released("thrust"):
		flip = !flip
		update_active_cylinder()

	apply_hover(delta, ray_casts_bottom, pid_controller_bottom, Vector3(0, 30, 0))
	apply_hover(delta, ray_casts_top, pid_controller_top, Vector3(0, -21, 0))
	apply_hover(delta, ray_casts_right, pid_controller_right, Vector3(-10, 0, 0))
	apply_hover(delta, ray_casts_left, pid_controller_left, Vector3(10, 0, 0))

	var particles = %ParticlesRight if flip else %ParticlesLeft
	if Input.is_action_pressed("thrust"):
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


func apply_hover(delta: float, ray_casts, pid_controller, thrust_vec):
	var dist = 10.0

	for ray_cast in ray_casts:
		ray_cast.obj.position = position + ray_cast.offset
		if ray_cast.obj.is_colliding():
			var hit_point = ray_cast.obj.get_collision_point()
			dist = min(dist, ray_cast.obj.global_position.distance_to(hit_point))

	var thrust = 0
	var pid_output = pid_controller.calculate(1, dist, delta)
	#print(pid_output, " ", dist)
	thrust = max(0, pid_output)
	apply_force(thrust_vec * thrust)
