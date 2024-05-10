extends RigidBody2D

var player
var player_ready : bool
var moving_dir : Vector2

func _process(delta):
	if player_ready && Input.is_action_pressed("Move_Box"):
		moving_dir = player.velocity
		moving_dir = moving_dir.normalized()
		position.x += moving_dir.x * player.moving_box_speed * delta

func _on_check_for_player_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_ready = true

func _on_check_for_player_body_exited(body):
	if body.is_in_group("Player"):
		player_ready = false
