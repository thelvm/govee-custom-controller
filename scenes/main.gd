extends BoxContainer

@onready var govee_connector: GoveeConnector = $GoveeConnector
@onready var devices_container: HBoxContainer = $DevicesContainer

const DEVICE_VIEW = preload("uid://fj80gipotni7")


func _ready() -> void:
	update_device_views()


func update_device_views():
	if not devices_container:
		return
	for child in devices_container.get_children():
		child.queue_free()
	for device in govee_connector.devices:
		var new_device_view := DEVICE_VIEW.instantiate() as DeviceView
		new_device_view.govee_device = device
		devices_container.add_child(new_device_view)
