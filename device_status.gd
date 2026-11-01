class_name DeviceStatus
extends RefCounted


var state: bool = false
var color: Color = Color.BLACK
var temperature: int = 0

static func from_data(data: Dictionary) -> DeviceStatus:
	var new_device_status := DeviceStatus.new()
	return new_device_status
