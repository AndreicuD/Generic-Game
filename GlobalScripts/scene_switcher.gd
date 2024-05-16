extends Node

var current_level : Node2D
var is_loading_level : bool = false

var next_level = null
var next_level_name : String

func _ready():
	current_level = get_tree().get_first_node_in_group("Level")

func change_level(wanted_level_name : String):
	if is_loading_level:
		return
	is_loading_level=true

	next_level = load("res://Levels/" + wanted_level_name + ".tscn").instantiate()
	$TransitionManager.play_transition("Fade_In")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"Fade_In":
			Global.reset_player_position_and_health()

			#also clean the level of any projectiles
			for projectile in get_tree().get_nodes_in_group('Projectile'):
				projectile.queue_free()

			current_level.queue_free()
			current_level=next_level
			add_child(current_level)

			var Player = get_tree().get_first_node_in_group("Player")
			Player.position.x = 0
			Player.position.y = 0
			if Player.has_method('reset_location()'):
				Player.reset_location()
			$TransitionManager.play_transition("Fade_Out")
		"Fade_Out":
			is_loading_level=false
			next_level=null
