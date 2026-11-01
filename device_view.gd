class_name DeviceView

extends Control

var govee_device: GoveeDevice: set = _set_govee_device

@onready var ip_value: Label = %IpValue
@onready var sku_value: Label = %SkuValue
@onready var device_value: Label = %DeviceValue
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var temperature_slider: HSlider = %TemperatureSlider


func _ready() -> void:
	update_device_view()


func update_device_view():
	if ip_value and sku_value and device_value and govee_device:
		ip_value.text = govee_device.ip
		sku_value.text = govee_device.sku
		device_value.text = govee_device.device


func turn_on():
	if govee_device:
		govee_device.turn_on()


func turn_off():
	if govee_device:
		govee_device.turn_off()


func handle_brightness_slider(value_changed: bool):
	if value_changed:
		govee_device.set_brightness(brightness_slider.value)


func set_color(color: Color):
	govee_device.set_color(color)


func handle_temperature_slider(value_changed: bool):
	if value_changed:
		govee_device.set_temperature(temperature_slider.value)


func _set_govee_device(new_govee_device: GoveeDevice):
	govee_device = new_govee_device
	update_device_view()
