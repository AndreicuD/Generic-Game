extends Control

func _ready():
	$Panel/cost.text = Global.heal_lvl1_cost
	$Panel/Buy.text = 'Buy'

func _on_buy_pressed():
	var abil_cost = $Panel/cost
	var cost = int(abil_cost.text)
	if Global.CURRENCY >= cost:
		Global.CURRENCY -= cost
	else:
		$Panel/Buy.text = "Can't afford!"
