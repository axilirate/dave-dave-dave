class_name ChatLog
extends RichTextLabel


onready var network_data: NetworkData = DataLoader.network_data

var _signal


func _ready():
	_signal = network_data.connect("packet_received", self, "_on_packet_received")



func _on_packet_received():
	var packet = network_data.received_packet
	if packet is ChatPacket:
		text += "\n" + packet.text
