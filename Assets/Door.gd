extends Area2D

@export var wanted_level : String

@onready var anim : AnimatedSprite2D = $DoorSprite
@onready var PopUp : CanvasLayer = $"PopUp"
@export var needs_key : bool
var is_active : bool = false
var player
var is_opened : bool = false

func _ready():
	if needs_key:
		anim.play("closed_key")
	else:
		anim.play("closed_no_key")

func _process(_delta):
	if Input.is_action_just_pressed("Interact") && is_active:
		if !is_opened:
			if needs_key:
				if player.has_key == true:
					player.has_key = false
					get_tree().get_first_node_in_group("active_key").queue_free()
					is_opened = true
					anim.play("opened")
				else:
					PopUp.set_visible(true)
			else:
				anim.play("opened")
				is_opened = true
		elif is_opened:
			get_tree().get_first_node_in_group("scene_manager").change_level(wanted_level)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		is_active = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_active = false
		player = null
		PopUp.set_visible(false)

func _on_button_pressed():
	PopUp.set_visible(false)
