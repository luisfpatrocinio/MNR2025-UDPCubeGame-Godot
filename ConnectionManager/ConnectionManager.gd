extends Node

const BROADCAST_IP = "192.168.137.255";
const BROADCAST_PORT = 1234;

## Porta UDP na qual o servidor irá escutar conexões.
const PORT = 5000;

## Instância do servidor UDP para receber conexões.
var server := UDPServer.new();

## Lista de peers conectados via UDP.
var peers: Array[PacketPeerUDP] = [];

## Dicionário que armazena o estado atual do input (eixos e botões).
var inputDict: Dictionary = {
	"xAxis": 0.0,
	"yAxis": 0.0,
	"buttonA": false,
	"buttonB": false,
}

# Cria client para envio de pacotes UDP
var client: PacketPeerUDP = PacketPeerUDP.new();

# Flag de estado de conexão
var connectionEstablished: bool = false;

# Sinal para quando um player se conecta
signal playerConnected(playerId: String);

# Sinal para quando o botão A é pressionado
signal buttonAPressed;

# Sinal para quando o botão B é pressionado
signal buttonBPressed;

## Gerencia pacotes recebidos e atualiza o dicionário de inputs com base no tipo de pacote.
## Pacotes que começam com "A" contêm dados do analógico.
## Pacotes que começam com "B" indicam um botão pressionado.
func managePacket(packet: String):
	# Checar se a mensagem é um ack
	if packet == "udp_handshake_ack":
		print("CONEXÃO ESTABELECIDA!");
		connectionEstablished = true;
		return ;
		
	# Se a mensagem não for um ack, processa o pacote
	var _firstChar = packet[0];
	match _firstChar:
		"A":
			var _vector = packet.split_floats("|", false).slice(1);
			inputDict.set("xAxis", _vector[0]);
			inputDict.set("yAxis", _vector[1]);
		"B":
			var _buttonId = int(packet.split_floats("|", false).slice(1)[0]);
			match _buttonId:
				0:
					inputDict.set("buttonA", true);
					print("BUTTON PRESSED: A");
					emit_signal("buttonAPressed");
				1:
					inputDict.set("buttonB", true);
					print("BUTTON PRESSED: B");
					emit_signal("buttonBPressed");


## Inicia o servidor para escutar conexões na porta especificada.
func _ready() -> void:
	server.listen(PORT)


## Função chamada a cada frame. Lida com polling de rede, nova conexão de peers e atualização de pacotes.
func _process(delta: float) -> void:
	server.poll();
	resetButtons();
	
	# Verifica se há uma nova conexão de cliente
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		var packet := peer.get_packet()
		print("New peer connected: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		
		# Processa o primeiro pacote recebido
		managePacket(packet.get_string_from_utf8());
		
		# Envia confirmação de conexão
		peer.put_packet(str("connected").to_utf8_buffer());
		send_data("connected");
		
		# Armazena o peer para comunicação futura
		peers.append(peer)
		
		emit_signal("playerConnected", peer.get_packet_ip());
	else:
		# Atualiza os pacotes recebidos dos peers existentes
		update_peers_and_packets()
		

## Limpa a lista de peers conectados.
func clearPeers() -> void:
	peers.clear();


## Reseta os botões no dicionário de input para `false`.
func resetButtons() -> void:
	inputDict.set("buttonA", false);
	inputDict.set("buttonB", false);


## Atualiza os peers conectados e processa pacotes recebidos de cada um.
func update_peers_and_packets() -> void:
	for i in range(0, peers.size()):
		var _thisPeer = peers[i];
		var _packet = _thisPeer.get_packet();
		if _packet:
			managePacket(_packet.get_string_from_utf8());


## Envia uma mensagem em string para todos os peers conectados.
func send_data(message: String):
	for peer: PacketPeerUDP in peers:
		var _ip = peer.get_packet_ip()
		var _msg = message.to_utf8_buffer();
		print("Sending to %s | Message: %s" % [_ip, message])
		peer.put_packet(_msg);


## Envia um pacote de handshake UDP via broadcast para descobrir e estabelecer conexão com o servidor.
## Esta função só envia o broadcast se ainda não houver uma conexão estabelecida (connectionEstablished = false).
## O broadcast é enviado para o endereço e porta definidos pelas constantes BROADCAST_IP e BROADCAST_PORT.
## Após enviar o broadcast, o servidor responderá com um "udp_handshake_ack" que será processado pela função managePacket().
func sendBroadcast():
	if !connectionEstablished:
		client.set_broadcast_enabled(true);
		client.set_dest_address(BROADCAST_IP, BROADCAST_PORT);
		client.put_packet("udp_handshake".to_utf8_buffer());
		print("Enviando broadcast para %s ..." % [BROADCAST_IP]);
		return ;
