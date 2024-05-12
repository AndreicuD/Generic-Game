extends CharacterBody2D

var can_move = true
var can_move_box = false
var can_dash = true

var direction
var is_dead = false
var is_dashing : bool = false
var is_moving_box : bool = false

var current_speed = 150.0
@export var speed = 150.0
@export var moving_box_speed = 100.0
@export var jump_power = 450.0
@export var dash_power = 450.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_cooldown : Timer = $Dash_Cooldown
@onready var dash_time : Timer = $Dash_Time

var has_key : bool = false

func _physics_process(delta):
	is_moving_box = false

	if !is_dashing:
		direction = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
		velocity.y += gravity*delta
		velocity.y = clamp(velocity.y, -300, 300)
		current_speed = speed

	if !is_on_floor():
		if !is_dashing:
			anim.play("Jumping")

	if Input.is_action_just_pressed("Jump") and is_on_floor() && can_move:
		velocity.y -= jump_power

	if direction && can_move:
		if direction.x < 0:
			anim.set_scale(Vector2(-1, 1))
		elif direction.x > 0:
			anim.set_scale(Vector2(1, 1))
		if is_on_floor() && !is_dashing:
			anim.play("Running")

		if Input.is_action_pressed("Move_Box") && can_move_box:
			current_speed = 50
			is_moving_box = true

		velocity.x = direction.x * current_speed

		if Input.is_action_just_pressed("Dash") && can_dash && (Global.can_dash_horizontal || Global.can_dash_any_direction):
			dash_time.start()
			dash_cooldown.start()
			can_dash = false
			if(Global.invicibility_when_dashing):
				Global.can_damage_player = false
			elif(Global.take_less_damage_when_dashing):
				Global.DAMAGE_TAKEN_MULTIPLIER = Global.take_less_damage_when_dashing_multiplier
			if Global.can_dash_any_direction:
				velocity = direction
				velocity = velocity.normalized() * current_speed
			else:
				velocity.x = direction.x * dash_power
			anim.play("Dashing")
			current_speed = dash_power
			is_dashing = true

	else:
		if is_on_floor() && !is_dashing:
			anim.play("Idle")
		if !is_dashing:
			velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Danger"):
			#can_move = false
			#anim.play("Dead")
			Global.player_death()

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_time_timeout():
	current_speed = speed
	if(Global.invicibility_when_dashing):
		Global.can_damage_player = true
	elif(Global.take_less_damage_when_dashing):
		Global.DAMAGE_TAKEN_MULTIPLIER = 1.0
	is_dashing = false

func _on_check_for_box_body_entered(body):
	if body.is_in_group("Box"):
		can_dash = false
		can_move_box = true

func _on_check_for_box_body_exited(body):
	if body.is_in_group("Box"):
		can_dash = true
		can_move_box = false
