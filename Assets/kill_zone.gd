extends Area2D

func _on_body_entered(body):
	if body.is_in_group('Player'):
		Global.reset_player_position_and_health()
