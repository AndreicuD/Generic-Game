extends Area2D

@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

@onready var PopUp : CanvasLayer = $"PopUp"
@onready var down_button : Button = $"PopUp/Panel/Ok Button"

var is_active : bool

func _process(_delta):
	if is_active:
		ExclMark.set_visible(true)
		ExclMarkAnim.play("Up-Down")
		if Input.is_action_just_pressed("Interact"):
			PopUp.set_visible(true)
	else:
		ExclMark.set_visible(false)
		PopUp.set_visible(false)

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		is_active=true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		is_active=false

func _on_ok_button_pressed():
	PopUp.set_visible(false)

func _on_cancel_button_pressed():
	PopUp.set_visible(false)
