extends Area2D

var is_active = false

@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

@onready var PopUp : CanvasLayer = $"PopUp"
@onready var down_button : Button = $"PopUp/Panel/Ok Button"

@onready var space1 = $"PopUp/Panel/Space1"
@onready var space2 = $"PopUp/Panel/Space2"
@onready var space3 = $"PopUp/Panel/Space3"

@export var cards = []
var card1
var card2
var card3

func _ready():
	Global.cards = cards
	card1 = cards.pick_random().instantiate()
	cards.erase(card1)
	card2 = cards.pick_random().instantiate()
	cards.erase(card2)
	card3 = cards.pick_random().instantiate()
	cards.erase(card3)

	card1.position = space1.position
	card2.position = space2.position
	card3.position = space3.position

	$PopUp/Panel.add_child(card1)
	$PopUp/Panel.add_child(card2)
	$PopUp/Panel.add_child(card3)

func _process(_delta):
	if Input.is_key_pressed(KEY_0):
		print(cards)
	if is_active:
		ExclMark.set_visible(true)
		ExclMarkAnim.play("Up-Down")
		if Input.is_action_just_pressed("Interact"):
			PopUp.set_visible(true)
	else:
		ExclMark.set_visible(false)
		PopUp.set_visible(false)

func _on_ok_button_pressed():
	PopUp.set_visible(false)

func _on_body_entered(body):
	if body.is_in_group('Player'):
		is_active = true
func _on_body_exited(body):
	is_active= false
	PopUp.set_visible(false)
