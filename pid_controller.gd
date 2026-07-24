class_name PidController

@export var params: PidControllerParams

var integral: float = 0.0
var last_current: float = 0.0
var last_output: float = 0.0

func _init(p: PidControllerParams):
	params = p

func calculate(target: float, current: float, delta: float) -> float:
	var error = target - current
	integral += error * delta
	integral = clamp(integral, -params.max_integral, params.max_integral)

	if params.derivative_input_smoothing > 0.0:
		var alpha = 1.0 - exp(-delta / params.derivative_input_smoothing)
		current = last_current + alpha * (current - last_current)

	# This is a "type B" PID controller, which makes the derivative term not react to sudden changes in the target.
	# https://apmonitor.com/pdc/index.php/Main/ProportionalIntegralDerivative
	var derivative = - (current - last_current) / delta
	var output = (params.p * error) + (params.i * integral) + (params.d * derivative)
	'''EventBus.debug_set_key.emit(
		params.resource_path.rsplit("/")[-1].rsplit(".")[0],
		"e=%.3f e2=%.3f i=%.3f d=%.3f o=%.3f" % [error, (current - last_current) * 100, integral, derivative, output],
		10
	)'''

	if params.output_smoothing > 0.0:
		var alpha_output = 1.0 - exp(-delta / params.output_smoothing)
		output = last_output + alpha_output * (output - last_output)
	if params.max_output_magnitude > 0.0:
		output = clamp(output, -params.max_output_magnitude, params.max_output_magnitude)
	last_current = current
	last_output = output
	return output
