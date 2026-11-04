class_name DeviceView

extends Control

var govee_device: GoveeDevice: set = _set_govee_device

@onready var device_friendly_label: Label = %DeviceFriendlyLabel
@onready var device_friendly_edit: LineEdit = %DeviceFriendlyEdit

@onready var ip_value: Label = %IpValue
@onready var sku_value: Label = %SkuValue
@onready var device_value: Label = %DeviceValue

@onready var online_status_label: Label = %OnlineStatusLabel
@onready var on_off_button: CheckButton = %OnOffButton
@onready var brightness_slider: HSlider = %BrightnessSlider
@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var temperature_slider: HSlider = %TemperatureSlider


func _ready() -> void:
	update_device_details()
	update_values_from_device_status()
	request_device_status()


func update_device_details():
	if ip_value and sku_value and device_value and govee_device and device_friendly_label:
		device_friendly_label.text = govee_device.friendly
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
	if online_status_label:
		online_status_label.text = "Online" if govee_device.is_online else "Offline"
	if on_off_button:
		if govee_device.is_online:
			on_off_button.disabled = false
			on_off_button.set_pressed_no_signal(govee_device.device_status.on_off)
		else:
			on_off_button.disabled = true
	if brightness_slider:
		if govee_device.is_online:
			brightness_slider.editable = true
			brightness_slider.set_value_no_signal(govee_device.device_status.brightness)
		else:
			brightness_slider.editable = false
	if color_picker_button:
		if govee_device.is_online:
			color_picker_button.disabled = false
			color_picker_button.color = govee_device.device_status.color
		else:
			color_picker_button.disabled = true
	if temperature_slider:
		if govee_device.is_online:
			temperature_slider.editable = true
			temperature_slider.set_value_no_signal(govee_device.device_status.temperature)
		else:
			temperature_slider.editable = false


func _set_govee_device(new_govee_device: GoveeDevice):
	govee_device = new_govee_device
	update_device_details()
	update_values_from_device_status()
	govee_device.device_status_updated.connect(update_values_from_device_status)


func _on_device_friendly_label_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.double_click:
			device_friendly_label.visible = false
			device_friendly_edit.visible = true
			device_friendly_edit.text = device_friendly_label.text
			device_friendly_edit.edit()
			device_friendly_edit.caret_column = device_friendly_edit.text.length()


func _on_device_friendly_edit_editing_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		device_friendly_label.text = device_friendly_edit.text
		device_friendly_label.visible = true
		device_friendly_edit.visible = false
		govee_device.update_friendly(device_friendly_edit.text)
