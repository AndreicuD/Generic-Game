extends Node2D

@export var global_scene : PackedScene

func _on_quit_pressed():
	get_tree().quit()

func _on_settings_pressed():
	$"Main Menu/Settings_Canvas".set_visible(true)
func _on_close_settings_pressed():
	$"Main Menu/Settings_Canvas".set_visible(false)

func _on_play_pressed():
	$"Main Menu/Tutorial_Popup".set_visible(true)
func _on_close_tutorial_popup_pressed():
	$"Main Menu/Tutorial_Popup".set_visible(false)
func _on_tutorial_yes_pressed():
	$"Main Menu/AnimationPlayer".play('fade')
	await get_tree().create_timer(1).timeout
	var global = global_scene.instantiate()
	add_sibling(global)
	queue_free()
	$"Main Menu/AnimationPlayer".play('out')
func _on_tutorial_no_pressed():
	$"Main Menu/AnimationPlayer".play('fade')
	await get_tree().create_timer(1).timeout
	var global = global_scene.instantiate()
	add_sibling(global)
	get_tree().get_first_node_in_group('scene_manager').change_level('Main_Room')
	get_tree().get_first_node_in_group('tutorial').queue_free()
	$"Main Menu/AnimationPlayer".play('out')
