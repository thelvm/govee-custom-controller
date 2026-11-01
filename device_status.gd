class_name DeviceStatus
extends RefCounted


var on_off: bool = false
var brighness: float = 0
var color: Color = Color.BLACK
var temperature: int = 0

static func from_device_status_response(response: Dictionary) -> DeviceStatus:
	var data: Dictionary
	if response["msg"]["data"]:
		data = response["msg"]["data"] as Dictionary
	
	var new_device_status := DeviceStatus.new()
	
	if data["onOff"] == 0:
		new_device_status.on_off = false
	else:
		new_device_status.on_off = true
	
	new_device_status.brighness = int(data["brightness"])
	
	new_device_status.color.r8 = int(data["color"]["r"])
	new_device_status.color.g8 = int(data["color"]["g"])
	new_device_status.color.b8 = int(data["color"]["b"])
	
	new_device_status.temperature = int(data["colorTemInKelvin"])
	
	return new_device_status
