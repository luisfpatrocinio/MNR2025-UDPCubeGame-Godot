extends Node3D

@onready var camera : Camera3D = get_node("Camera3D");
@onready var patroCube : CSGBox3D = get_node("PatroCube");

func _process(delta: float) -> void:
	var _ang = Time.get_ticks_msec() / 1000.0;
	camera.position.y = 2 + 0.50 * sin(_ang) * 0.100
	camera.look_at(patroCube.position);
