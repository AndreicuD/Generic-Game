extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

func damage(_damage):
	anim.rotation = -0.1
	await get_tree().create_timer(0.05).timeout
	anim.rotation = 0
