class_name DeviceView

extends Control

var govee_device: GoveeDevice: set = _set_govee_device

@onready var ip_value: Label = %IpValue
@onready var sku_value: Label = %SkuValue
@onready var device_value: Label = %DeviceValue

@onready var on_off_button: CheckButton = %OnOffButton
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var temperature_slider: HSlider = %TemperatureSlider


func _ready() -> void:
	update_device_details()
	update_values_from_device_status()


func update_device_details():
	if ip_value and sku_value and device_value and govee_device:
		ip_value.text = govee_device.ip
		sku_value.text = govee_device.sku
		device_value.text = govee_device.device


func set_power(power: bool):
	if power:
		turn_on()
	else:
		turn_off()


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


func request_device_status():
	govee_device.request_device_status()


func update_values_from_device_status():
	if not govee_device:
		return
	if on_off_button:
		on_off_button.set_pressed_no_signal(govee_device.device_status.on_off)
	if brightness_slider:
		brightness_slider.set_value_no_signal(govee_device.device_status.brighness)
	if color_picker_button:
		color_picker_button.color = govee_device.device_status.color
	if temperature_slider:
		temperature_slider.set_value_no_signal(govee_device.device_status.temperature)


func _set_govee_device(new_govee_device: GoveeDevice):
	govee_device = new_govee_device
	update_device_details()
	update_values_from_device_status()
	govee_device.device_status_updated.connect(update_values_from_device_status)
