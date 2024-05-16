extends Control

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	$Settings_Canvas.set_visible(true)
func _on_close_settings_pressed():
	$Settings_Canvas.set_visible(false)
