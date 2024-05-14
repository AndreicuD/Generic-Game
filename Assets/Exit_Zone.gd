extends Area2D

var levels = ['Level1']

func _on_body_entered(body):
	if(body.is_in_group('Player')):
		get_tree().get_first_node_in_group("scene_manager").change_level(levels.pick_random())
