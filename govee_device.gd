class_name GoveeDevice
extends RefCounted

signal device_status_updated

@export_storage var friendly: String = ""
@export_storage var device: String = ""
@export_storage var ip: String = "" : set = _set_ip
@export_storage var sku: String = ""

var command_sender := PacketPeerUDP.new()
var device_status := DeviceStatus.new()

## Creates a new [GoveeDevice] from a scan response packet 
static func from_scan_response(scan_response: Variant) -> GoveeDevice:
	var new_device = GoveeDevice.new()
	new_device.friendly = scan_response["msg"]["data"]["device"]
	new_device.device = scan_response["msg"]["data"]["device"]
	new_device.ip = scan_response["msg"]["data"]["ip"]
	new_device.sku = scan_response["msg"]["data"]["sku"]
	return new_device


func _set_ip(new_ip: String) -> void:
	ip = new_ip
	command_sender.set_dest_address(ip, 4003)
	request_device_status()


func turn_on() -> void:
	var command := {
			"msg": {
				"cmd": "turn",
				"data": {
					"value": 1
				}
			}
		}
	
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())


func turn_off() -> void:
	var command := {
			"msg": {
				"cmd": "turn",
				"data": {
					"value": 0
				}
			}
		}
		
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())


func set_brightness(value: float) -> void:
	var command := {
		"msg": {
			"cmd": "brightness",
			"data": {
				"value": int(value)
				}
			}
		}
		
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())


func set_color(color: Color) -> void:
	var command := {
		"msg": {
			"cmd": "colorwc",
			"data": {
				"color": {
					"r": color.r8,
					"g": color.g8,
					"b": color.b8
				},
				"colorTemInKelvin": 0
			}
		}
	}
	
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())


func set_temperature(value: float) -> void:
	var command := {
		"msg": {
			"cmd": "colorwc",
			"data": {
				"color": {
					"r": 255,
					"g": 255,
					"b": 255
				},
				"colorTemInKelvin": int(value)
			}
		}
	}
	
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())


func request_device_status() -> void:
	var command := {
		"msg": {
			"cmd": "devStatus",
			"data": {}
		}
	}
	
	var command_string := JSON.stringify(command)
	command_sender.put_packet(command_string.to_ascii_buffer())

func update_device_status_from_response(response) -> void:
	device_status = DeviceStatus.from_device_status_response(response)
	device_status_updated.emit()
