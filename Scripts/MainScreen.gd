extends CanvasLayer

@onready var disconnectBlock = get_node("DisconnectBlock");
@onready var cubePanel = get_node("CubeFace");

func _ready() -> void:
	ConnectionManager.connect("playerConnected", _onPlayerConnected);
	disconnectBlock.visible = true;
	cubePanel.visible = false;
	
func _onPlayerConnected(_playerId: String) -> void:
	print("Player connected.");
	print(_playerId);
	disconnectBlock.visible = false;
	cubePanel.visible = true;

func _process(_delta: float) -> void:
	if ConnectionManager.connectionEstablished:
		var _label = cubePanel.get_node("FaceNumberLabel") as Label;
		_label.text = str(ConnectionManager.inputDict["faceNo"]);
