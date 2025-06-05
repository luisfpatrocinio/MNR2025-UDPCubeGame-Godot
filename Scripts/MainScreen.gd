extends CanvasLayer

@onready var disconnectBlock: Control = get_node("DisconnectBlock");
@onready var cubePanel: Panel = get_node("CubeFace");

@onready var patroCube: CSGBox3D = get_node("World/PatroCube");

@onready var debugLabel: Label = get_node("DebugLabel");

func _ready() -> void:
	ConnectionManager.connect("playerConnected", _onPlayerConnected);
	ConnectionManager.connect("faceChanged", _onFaceChanged);
	disconnectBlock.visible = true;
	cubePanel.visible = false;
	
func _onPlayerConnected(_playerId: String) -> void:
	print("Player connected.");
	print(_playerId);
	disconnectBlock.visible = false;
	cubePanel.visible = true;

func _onFaceChanged(_newFaceValue) -> void:
	print("Nova face: %d" % [_newFaceValue]);
	SetCubeFace(_newFaceValue);

func _process(_delta: float) -> void:
	var _roll = ConnectionManager.inputDict["roll"];
	var _pitch = ConnectionManager.inputDict["pitch"];
	# Rotate cube - Pitch
	var _newRotationY = -90 / 11 * _roll;
	_newRotationY = deg_to_rad(_newRotationY);
	var _newRotationX = -90 / 11 * _pitch;
	_newRotationX = deg_to_rad(_newRotationX);

	#print("PatroCube rotation: %f, %f, %f" % [patroCube.rotation.x, patroCube.rotation.y, patroCube.rotation.z]);
	#print("New rotation: %f, %f" % [_newRotationX, _newRotationY]);
	
	# patroCube.rotation = patroCube.rotation.move_toward(Vector3(_newRotationX, _newRotationY, 0), 0.20);
	patroCube.rotation.x = move_toward(patroCube.rotation.x, _newRotationX, 0.05);
	patroCube.rotation.z = move_toward(patroCube.rotation.z, _newRotationY, 0.05);
	patroCube.position.y = lerp(patroCube.position.y, 2.0 * float(ConnectionManager.inputDict["rolling"]), 0.10)
	
	debugLabel.text = "DEBUG:\n";
	debugLabel.text += "Pitch: %d\n" % ConnectionManager.inputDict["pitch"];
	debugLabel.text += "Roll: %d\n" % ConnectionManager.inputDict["roll"];
	pass

func SetCubeFace(_newCubeFace) -> void:
	var _label = cubePanel.get_node("FaceNumberLabel") as Label;
	_label.text = str(ConnectionManager.inputDict["faceNo"]);
	
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(2.0, 2.0), 0.10).finished;
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(1.0, 1.0), 0.10).finished;
