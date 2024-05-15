extends Area2D

@export_multiline var text = ''
@export var only_once : bool = false

@onready var canvas = $CanvasLayer

func _ready():
	$CanvasLayer/Panel/Label.text = text

func _on_body_entered(body):
	if body.is_in_group('Player'):
		canvas.set_visible(true)

func _on_body_exited(body):
	if body.is_in_group('Player'):
		canvas.set_visible(false)
		if only_once:
			queue_free()
