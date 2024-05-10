extends Area2D

var is_active : bool = false
var player

func _process(delta):
	if(is_active):
		position = lerp(position, player.position + Vector2(12, -15), delta*2)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player=body
		player.has_key = true
		self.add_to_group("active_key")
		is_active=true
