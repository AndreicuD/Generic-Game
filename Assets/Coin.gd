extends Area2D

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		collected()

func collected():
	Global.CURRENCY += 5
	$AudioStreamPlayer.playing = true
	$CollisionShape2D.disabled = true
	$CoinSprite.set_visible(false)
	await get_tree().create_timer(1).timeout
	queue_free()
