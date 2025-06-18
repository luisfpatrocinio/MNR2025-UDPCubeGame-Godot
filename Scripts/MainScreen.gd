extends CanvasLayer

## Disconnect Block Interface
@onready var disconnectBlock: Control = get_node("DisconnectBlock");
## Panel that shows the cube face number
@onready var cubePanel: Panel = get_node("CubeFace");
## 3D object representing the cube
@onready var patroCube: CSGBox3D = get_node("World/PatroCube");
## Debug Mode flag
var showDebug : bool = false;
## Debug Label
@onready var debugLabel: Label = get_node("DebugLabel");

func _ready() -> void:
	ConnectionManager.connect("playerConnected", _onPlayerConnected);
	ConnectionManager.connect("faceChanged", _onFaceChanged);
	ConnectionManager.connect("connectionLost", _onConnectionLost);
	ConnectionManager.connect("heartbeat", _onHeartbeat);
	disconnectBlock.visible = true;
	cubePanel.visible = false;
	
func _onPlayerConnected(_playerId: String) -> void:
	print("Player connected.");
	print(_playerId);
	disconnectBlock.visible = false;
	cubePanel.visible = true;
	
func _onHeartbeat() -> void:
	disconnectBlock.visible = false;
	
	pass

func _onFaceChanged(_newFaceValue) -> void:
	print("Nova face: %d" % [_newFaceValue]);
	SetCubeFace(_newFaceValue);
	
func _onConnectionLost() -> void:
	print("Conexão perdida.");
	disconnectBlock.visible = true;

func _process(_delta: float) -> void:
	# Toggle Debug Mode
	if Input.is_action_just_pressed("ui_page_up"):
		showDebug = !showDebug;
	
	var _roll = ConnectionManager.inputDict["roll"];
	var _pitch = ConnectionManager.inputDict["pitch"];
	var _yaw = ConnectionManager.inputDict["yaw"]
	
	# Rotate cube - Pitch
	var _newRotationY = -90 / 11 * _roll;
	_newRotationY = deg_to_rad(_newRotationY);
	var _newRotationX = -90 / 11 * _pitch;
	_newRotationX = deg_to_rad(_newRotationX);

	#print("PatroCube rotation: %f, %f, %f" % [patroCube.rotation.x, patroCube.rotation.y, patroCube.rotation.z]);
	#print("New rotation: %f, %f" % [_newRotationX, _newRotationY]);
	
	# patroCube.rotation = patroCube.rotation.move_toward(Vector3(_newRotationX, _newRotationY, 0), 0.20);
	patroCube.rotation.x = lerp(patroCube.rotation.x, _newRotationX, 0.05);
	patroCube.rotation.z = lerp(patroCube.rotation.z, _newRotationY, 0.05);
	#patroCube.rotation.y = deg_to_rad(_yaw);
	patroCube.position.y = lerp(patroCube.position.y, 2.0 * float(ConnectionManager.inputDict["rolling"]), 0.01)
	
	debugLabel.text = "DEBUG:\n";
	debugLabel.text += "Pitch: %d\n" % ConnectionManager.inputDict["pitch"];
	debugLabel.text += "Roll: %d\n" % ConnectionManager.inputDict["roll"];
	debugLabel.text += "Yaw: %d\n" % ConnectionManager.inputDict["yaw"];
	debugLabel.text += "Timer: %d\n" % ConnectionManager.get_node("HeartbeatTimer").time_left;
	pass

func SetCubeFace(_newCubeFace) -> void:
	var _label = cubePanel.get_node("FaceNumberLabel") as Label;
	_label.text = str(ConnectionManager.inputDict["faceNo"]);
	
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(2.0, 2.0), 0.10).finished;
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(1.0, 1.0), 0.10).finished;
