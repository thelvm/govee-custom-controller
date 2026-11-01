class_name GoveeConnector
extends Node

signal devices_changed

var scanner := PacketPeerUDP.new()
var listener := PacketPeerUDP.new()

var connected_interface_names: Array[String]
var devices: Array[GoveeDevice]


func _ready() -> void:
	listener.bind(4002)


func scan_available_devices():
	var interface_names: Array[String]
	connected_interface_names.clear()
	devices.clear()
	
	for interface in IP.get_local_interfaces():
		if interface.name:
			interface_names.append(interface.name)
	for interface_name in interface_names:
		var join_error = scanner.join_multicast_group("239.255.255.250", interface_name)
		if not join_error:
			connected_interface_names.append(interface_name)
	
	scanner.set_broadcast_enabled(true)
	scanner.set_dest_address("239.255.255.250", 4001)
	scanner.put_packet('{ "msg":{ "cmd":"scan", "data":{ "account_topic":"reserve" } } }'.to_ascii_buffer())


func _process(_delta: float) -> void:
	if listener.is_bound():
		if listener.get_available_packet_count() > 0:
			var raw_packet = listener.get_packet()
			var packet = JSON.parse_string(raw_packet.get_string_from_ascii())
			if packet["msg"]["cmd"] == "scan":
				var new_device = GoveeDevice.from_scan_response(packet)
				devices.append(new_device)
				devices_changed.emit()
