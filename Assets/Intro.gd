extends CanvasLayer

@onready var anim = $AnimationPlayer

func _ready():
	anim.play('autoplay')
