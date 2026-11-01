class_name GoveeDevice

extends RefCounted

var ip: String = "" : set = _set_ip
var device: String = ""
var sku: String = ""
#var color: Color = Color.BLACK
#var brightness: float = 0.0

var command_sender := PacketPeerUDP.new()


static func from_scan_response(scan_response: Variant) -> GoveeDevice:
	var new_device = GoveeDevice.new()
	new_device.ip = scan_response["msg"]["data"]["ip"]
	new_device.device = scan_response["msg"]["data"]["device"]
	new_device.sku = scan_response["msg"]["data"]["sku"]
	return new_device


func _set_ip(new_ip: String) -> void:
	ip = new_ip
	command_sender.set_dest_address(ip, 4003)


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
