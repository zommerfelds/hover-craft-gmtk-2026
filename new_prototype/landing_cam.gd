extends Camera3D

var player_offset: Vector3

func _ready() -> void:
	player_offset = position - %Player.position


func _physics_process(delta: float) -> void:
	position = %Player.position + player_offset
