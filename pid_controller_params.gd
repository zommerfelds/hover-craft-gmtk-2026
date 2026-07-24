class_name PidControllerParams
extends Resource

@export var p: float
@export var i: float
@export var d: float
@export var max_integral: float
@export var max_output_magnitude: float = 0.0
@export var derivative_input_smoothing: float = 0.0
@export var output_smoothing: float = 0.0
