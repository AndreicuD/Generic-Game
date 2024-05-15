extends Area2D

@onready var ExclMark : Sprite2D = $"Exclamation Mark"
@onready var ExclMarkAnim : AnimationPlayer = $"Exclamation Mark/AnimationPlayer"

@onready var PopUp : CanvasLayer = $"PopUp"
@onready var down_button : Button = $"PopUp/Panel/Ok Button"

var is_active : bool
var player

func _ready():
	player = get_tree().get_first_node_in_group('Player')

	$PopUp/Panel/Spear_Panel/Weapon_Cost.text = Global.spear_cost
	$PopUp/Panel/Sword_Panel/Weapon_Cost.text = Global.sword_cost
	$PopUp/Panel/Bow_Panel/Weapon_Cost.text   = Global.bow_cost

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
	$PopUp/Panel/Spear_Panel/Buy_Spear.text = 'Buy'
	$PopUp/Panel/Sword_Panel/Buy_Sword.text = 'Buy'
	$PopUp/Panel/Bow_Panel/Buy_Bow.text = 'Buy'

func _on_buy_spear_pressed():
	var spear_cost = $PopUp/Panel/Spear_Panel/Weapon_Cost
	var cost = int(spear_cost.text)
	#print('Cost:')
	#print(cost)
	if Global.CURRENCY >= cost:
		Global.CURRENCY -= cost
		Global.spear_cost = '0'
		spear_cost.text = Global.spear_cost
		player.choose_weapon('spear')

func _on_buy_sword_pressed():
	var sword_cost = $PopUp/Panel/Sword_Panel/Weapon_Cost
	var cost = int(sword_cost.text)
	#print('Cost:')
	#print(cost)
	if Global.CURRENCY >= cost:
		Global.CURRENCY -= cost
		Global.sword_cost = '0'
		sword_cost.text = Global.sword_cost
		player.choose_weapon('sword')
	else:
		$PopUp/Panel/Sword_Panel/Buy_Sword.text = "Can't afford!"

func _on_buy_bow_pressed():
	var bow_cost = $PopUp/Panel/Bow_Panel/Weapon_Cost
	var cost = int(bow_cost.text)
	#print('Cost:')
	#print(cost)
	if Global.CURRENCY >= cost:
		Global.CURRENCY -= cost
		Global.bow_cost = '0'
		bow_cost.text = Global.bow_cost
		player.choose_weapon('bow')
	else:
		$PopUp/Panel/Bow_Panel/Buy_Bow.text = "Can't afford!"
