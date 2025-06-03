extends CanvasLayer

@onready var disconnectBlock = get_node("DisconnectBlock");
@onready var cubePanel = get_node("CubeFace");

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
	pass

func SetCubeFace(_newCubeFace) -> void:
	var _label = cubePanel.get_node("FaceNumberLabel") as Label;
	_label.text = str(ConnectionManager.inputDict["faceNo"]);
	
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(2.0, 2.0), 0.10).finished;
	await get_tree().create_tween().tween_property(cubePanel, "scale", Vector2(1.0, 1.0), 0.10).finished;
