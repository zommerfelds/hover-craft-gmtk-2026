extends Camera3D

var player_offset: Vector3
var velocity = Vector2.ZERO
const pid_params = preload("res://pid_params_camera.tres")
@onready var pid_controller_x = PidController.new(pid_params)
@onready var pid_controller_y = PidController.new(pid_params)

func _ready() -> void:
	player_offset = position - %Player.position


func _physics_process(delta: float) -> void:
	# position = %Player.position + player_offset

	var target = %Player.position + player_offset
	var pid_output_x = pid_controller_x.calculate(target.x, position.x, delta)
	velocity.x += pid_output_x
	var pid_output_y = pid_controller_y.calculate(target.y, position.y, delta)
	velocity.y += pid_output_y
	# print(pid_output_x, " ", pid_output_y)

	position.x += velocity.x * delta
	position.y += velocity.y * delta
	position.z = position.z * 0.9 + (target.z + velocity.length() * 0.5) * 0.1
