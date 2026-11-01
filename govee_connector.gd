class_name GoveeConnector
extends Node

signal devices_changed
signal device_status_received()

var scanner := PacketPeerUDP.new()
var listener := PacketPeerUDP.new()

var connected_interface_names: Array[String]
var devices: Array[GoveeDevice]


func _ready() -> void:
	setup_scanner()
	setup_listener()


func setup_listener() -> void:
	listener.bind(4002)


func setup_scanner() -> void:
	connected_interface_names.clear()
	devices.clear()
	
	for interface in IP.get_local_interfaces():
		var join_error = scanner.join_multicast_group("239.255.255.250", interface["name"])
		if join_error:
			printerr("Could not join multicast group on :" + interface["friendly"])
		if not join_error:
			print("Joined multicast group on: " + interface["friendly"])
	scanner.set_broadcast_enabled(true)
	scanner.set_dest_address("239.255.255.250", 4001)


func scan_available_devices():
	var command := {
		"msg": {
			"cmd": "scan",
			"data": {
					"account_topic":"reserve"
				}
		}
	}
	var command_string = JSON.stringify(command)
	var error := scanner.put_packet(command_string.to_ascii_buffer())
	scanner.put_packet("Random packet".to_ascii_buffer())
	if error:
		printerr("Something happened when trying to scan devices")
	else:
		print("Sending scan request")


func _process(_delta: float) -> void:
	if listener.is_bound():
		if listener.get_available_packet_count() > 0:
			var raw_packet := listener.get_packet()
			var from_address := listener.get_packet_ip()
			var packet = JSON.parse_string(raw_packet.get_string_from_ascii())
			print("ip: " + from_address + " data: ")
			if packet:
				if packet["msg"]["data"]:
					print(packet["msg"]["data"])
				if packet["msg"]["cmd"] == "scan":
					var new_device = GoveeDevice.from_scan_response(packet)
					devices.append(new_device)
					devices_changed.emit()
