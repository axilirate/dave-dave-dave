extends OptionCheckBox





func _ready():
	options_data.connect("v_sync_changed", self, "_on_v_sync_changed")



func _on_v_sync_changed():
	_update_toggle()



func _update_toggle():
	pressed = options_data.v_sync


