class_name GoveeConnector
extends Node

signal devices_changed
signal device_status_received()

var valid_addresses: Array[String]

var scanners: Array[PacketPeerUDP]
var listeners: Array[PacketPeerUDP]

var devices: Array[GoveeDevice]


func _ready() -> void:
	configure_valid_addresses()
	setup_scanners()
	setup_listener()


func configure_valid_addresses():
	valid_addresses.clear()
	for interface in IP.get_local_interfaces():
		for address in interface["addresses"]:
			if (address as String).begins_with("192.168"):
				valid_addresses.append(address)


func setup_listener() -> void:
	listeners.clear()
	
	for valid_address in valid_addresses:
		var listener := PacketPeerUDP.new()
		listener.bind(4002, valid_address)
		listeners.append(listener)


func setup_scanners() -> void:
	scanners.clear()
	
	for valid_address in valid_addresses:
		var scanner := PacketPeerUDP.new()
		scanner.bind(0, valid_address)
		scanner.set_dest_address("239.255.255.250", 4001)
		scanners.append(scanner)


func scan_available_devices():
	var command := {
		"msg": {
			"cmd": "scan",
			"data": {
				"account_topic": "reserve"
			}
		},
	}
	var command_string = JSON.stringify(command)
	for scanner in scanners:
		var error := scanner.put_packet(command_string.to_ascii_buffer())
		if error:
			printerr("Something happened when trying to scan devices")
		else:
			print("Sending scan request")


func handle_listeners():
	for listener in listeners:
		if listener.is_bound():
			if listener.get_available_packet_count() > 0:
				var raw_packet := listener.get_packet()
				var from_address := listener.get_packet_ip()
				var packet = JSON.parse_string(raw_packet.get_string_from_ascii())
				print("ip: " + from_address + " data: ")
				if packet:
					if packet["msg"]["data"]:
						print(packet["msg"])
					if packet["msg"]["cmd"] == "scan":
						var device_already_mapped := false
						for device in devices:
							if device.ip == packet["msg"]["data"]["ip"]:
								device_already_mapped = true
								break
						if not device_already_mapped:
							var new_device = GoveeDevice.from_scan_response(packet)
							devices.append(new_device)
							devices_changed.emit()


func _process(_delta: float) -> void:
	handle_listeners()
