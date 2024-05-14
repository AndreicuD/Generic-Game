extends Area2D

@export var zone_name : String = 'outside'
@export var modulate_color : Color
@onready var canvas : CanvasModulate = $modulate

func _ready():
	canvas.color = modulate_color

func _on_body_entered(body):
	var tween = get_tree().create_tween()
	tween.tween_property(canvas, "color", modulate_color, 1)
	if body.has_method('change_zone'):
		body.change_zone(zone_name)
	#canvas.set_visible(true)

func _on_body_exited(_body):
	#canvas.set_visible(false)
	var tween = get_tree().create_tween()
	tween.tween_property(canvas, "color", Color.WHITE, 1)
