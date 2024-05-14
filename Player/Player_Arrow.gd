extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_loc
var movement

func _ready():
	look_at(target_loc)
	movement = position.move_toward(target_loc, 1) - position
	#position = position.move_toward(target_loc, delta * 500)

func _physics_process(delta):
	position += movement * delta * 500

func set_target_location(location):
	target_loc = location

func _on_coll_check_body_entered(body):
	if(body.has_method('damage')):
		body.damage(Global.DAMAGE * Global.DAMAGE_MULTIPLIER)
	queue_free()
