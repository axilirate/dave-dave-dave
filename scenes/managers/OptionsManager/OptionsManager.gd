class_name OptionsManager
extends Node



onready var options_editor: OptionsEditor = Game.options_data as OptionsEditor




func _ready():
	options_editor.connect("fullscreen_changed", self, "_on_fullscreen_changed")
	options_editor.connect("v_sync_changed", self, "_on_v_sync_changed")
	_update_fullscreen()
	_update_v_sync()


func _on_fullscreen_changed():
	_update_fullscreen()


func _on_v_sync_changed():
	_update_v_sync()






func _update_fullscreen():
	OS.window_fullscreen = Game.options_data.fullscreen


func _update_v_sync():
	OS.set_use_vsync(Game.options_data.v_sync)






func _on_FullscreenOptionCheckBox_toggled(button_pressed):
	options_editor.set_fullscreen(button_pressed)



func _on_VSyncOptionCheckBox_toggled(button_pressed):
	options_editor.set_v_sync(button_pressed)
