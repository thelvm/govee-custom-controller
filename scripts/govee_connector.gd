class_name GoveeConnector
extends Node

signal devices_changed
signal device_status_received

var valid_addresses: Array[String]

var scanners: Array[PacketPeerUDP]
var listeners: Array[PacketPeerUDP]

var devices: Array[GoveeDevice]


func _ready() -> void:
	configure_valid_addresses()
	setup_scanners()
	setup_listener()
	load_known_devices()


func _process(_delta: float) -> void:
	handle_listeners()


func configure_valid_addresses() -> void:
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


func load_known_devices() -> void:
	if not FileAccess.file_exists("user://devices.json"):
		return
	
	print("Loading known devices")
	var devices_file := FileAccess.open("user://devices.json", FileAccess.READ)
	var devices_object := JSON.parse_string(devices_file.get_as_text()) as Dictionary
	if not devices_object:
		print("Error loading known devices")
		return
	
	for device_data in devices_object["devices"]:
		devices.append(GoveeDevice.from_device_data(device_data))
	
	devices_changed.emit()


func scan_available_devices() -> void:
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


func handle_listeners() -> void:
	for listener in listeners:
		if listener.is_bound():
			if listener.get_available_packet_count() > 0:
				var raw_packet := listener.get_packet()
				var packet_ip := listener.get_packet_ip()
				var packet = JSON.parse_string(raw_packet.get_string_from_ascii())
				if packet:
					if packet["msg"]["cmd"] == "scan":
						process_scan_response(packet)
					if packet["msg"]["cmd"] == "devStatus":
						for device in devices:
							if device.ip == packet_ip:
								print("Status update received from " + packet_ip)
								device.update_device_status_from_response(packet)


func process_scan_response(response: Dictionary) -> void:
	var device_already_mapped := false
	
	var device_view_requires_update := false
	for device in devices:
		if device.device == response["msg"]["data"]["device"]:
			print("Device " + response["msg"]["data"]["device"] + " already mapped. Updating details")
			device.ip = response["msg"]["data"]["ip"]
			device.sku = response["msg"]["data"]["sku"]
			device_already_mapped = true
			device_view_requires_update = true
			break
	
	if not device_already_mapped:
		print("New device detected. Adding " + response["msg"]["data"]["device"])
		var new_device = GoveeDevice.from_scan_response(response)
		new_device.device_info_updated.connect(save_devices)
		devices.append(new_device)
		device_view_requires_update = true
	
	if device_view_requires_update:
		devices_changed.emit()


func save_devices() -> void:
	var data := {
		"version": 1
	}
	
	var devices_array := []
	for device in devices:
		devices_array.append(device.to_dict())
	
	data["devices"] = devices_array
	
	var devices_file := FileAccess.open("user://devices.json", FileAccess.WRITE)
	devices_file.store_string(JSON.stringify(data))
