extends Node2D

@export var hit80 : Texture
@export var hit60 : Texture
@export var hit40 : Texture
@export var hit20 : Texture

@onready var coin_text : Label = $'Overlay/Coins'
@onready var hit : TextureRect = $'Overlay/Hit'

func _process(_delta):
	coin_text.text = str(Global.CURRENCY)
	if(Global.HEALTH<=20):
		hit.texture = hit20
	elif(Global.HEALTH<=40):
		hit.texture = hit40
	elif(Global.HEALTH <= 60):
		hit.texture = hit60
	elif(Global.HEALTH <= 80):
		hit.texture = hit80
	else:
		hit.texture = null
