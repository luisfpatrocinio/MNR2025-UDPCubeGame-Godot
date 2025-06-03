extends CanvasLayer

@onready var disconnectBlock = get_node("DisconnectBlock");

func _ready() -> void:
	ConnectionManager.connect("playerConnected", _onPlayerConnected);
	disconnectBlock.visible = true;
	
func _onPlayerConnected(_playerId: String) -> void:
	print("Player connected.");
	print(_playerId);
	disconnectBlock.visible = false;
