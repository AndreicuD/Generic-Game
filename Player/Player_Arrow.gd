extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var target_loc
var movement
@onready var dam_audio = $damage_AudioPlayer
@onready var hit_audio = $hit_AudioPlayer
var can_move = true

func _ready():
	look_at(target_loc)
	movement = position.move_toward(target_loc, 1) - position
	#position = position.move_toward(target_loc, delta * 500)

func _physics_process(delta):
	if can_move:
		position += movement * delta * 500

func set_target_location(location):
	target_loc = location

func hit(body):
	can_move = false
	$AnimatedSprite2D.pause()
	if(body.has_method('damage')):
		dam_audio.play()
		body.damage(Global.DAMAGE * Global.DAMAGE_MULTIPLIER)
	else: hit_audio.play()
	await get_tree().create_timer(1).timeout
	var tween = get_tree().create_tween()
	tween.tween_property($AnimatedSprite2D, 'modulate:a', 0, 1)
	tween.tween_callback($AnimatedSprite2D.queue_free)
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_coll_check_body_entered(body):
	hit(body)

func _on_timer_timeout():
	hit(self)
