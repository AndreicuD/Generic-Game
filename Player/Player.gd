extends CharacterBody2D

var direction_x
var current_speed
@export var speed = 100.0
@export var moving_box_speed = 50.0
@export var jump_power = 225.0

var can_move : bool = true
var can_move_box : bool = false
var is_moving_box : bool = false
var is_dead : bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer : Timer = $Coyote_Timer
@onready var remember_jump_timer : Timer = $Remember_Jump_Timer

var has_key : bool = false

func _physics_process(delta):

	if !is_on_floor():
		anim.play("Jumping")

	velocity.y += gravity*delta
	velocity.y = clamp(velocity.y, -300, 300)

	if (Input.is_action_just_pressed("Jump") && can_move && is_on_floor()):
		velocity.y -= jump_power

	direction_x = Input.get_axis("Left", "Right")

	if direction_x && can_move:
		if direction_x < 0:
			anim.set_scale(Vector2(-1, 1))
		elif direction_x > 0:
			anim.set_scale(Vector2(1, 1))
		if is_on_floor():
			anim.play("Running")

		is_moving_box = false
		if Input.is_action_pressed("Move_Box") && can_move_box:
			current_speed = 50
			is_moving_box = true

		if !is_moving_box:
			current_speed = speed
		velocity.x = direction_x * current_speed

	else:
		if is_on_floor():
			anim.play("Idle")
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Danger"):
			#can_move = false
			#anim.play("Dead")
			Global.player_death()

func _on_check_for_box_body_entered(body):
	if body.is_in_group("Box"):
		can_move_box = true

func _on_check_for_box_body_exited(body):
	if body.is_in_group("Box"):
		can_move_box = false
