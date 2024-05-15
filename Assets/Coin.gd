extends Area2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		Global.CURRENCY += 5
		queue_free()
