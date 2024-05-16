extends Node2D

func _ready():
	var player = get_tree().get_first_node_in_group('Player')
	print(player)
	player.reset_location()
