extends CharacterBody2D

var can_move = true
var can_move_also_vertically = true
var can_move_box = false
var can_dash = true

var direction
var is_dead = false
var is_dashing : bool = false
var is_moving_box : bool = false

var enemy
var current_zone

var current_speed = 150.0
@export var speed = 150.0
@export var moving_box_speed = 100.0
@export var jump_power = 450.0
@export var dash_power = 450.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var normal_col_shape = $CollisionShape2D_Normal
@onready var dash_col_shape = $CollisionShape2D_Dash

@onready var swoosh_audio = $Swoosh_AudioPlayer
@onready var hit_audio = $Hits_AudioPlayer
@onready var grass_audio = $Grass_Foot_AudioPlayer
@onready var stone_audio = $Stone_Foot_AudioPlayer

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_cooldown : Timer = $Dash_Cooldown
@onready var dash_time : Timer = $Dash_Time
@onready var footsteps_timer : Timer = $Footsteps_Timer
@onready var attack_timer : Timer = $Time_Between_Attacks

var can_attack = true
@onready var spear_check = $Spear_Attack_Check
@onready var sword_check = $Sword_Attack_Check
@export var arrow : PackedScene

var has_key : bool = false

func _ready():
	choose_weapon('spear')

func _physics_process(delta):
	is_moving_box = false

	if Input.is_key_pressed(KEY_1):
		choose_weapon('spear')
	if Input.is_key_pressed(KEY_2):
		choose_weapon('sword')
	if Input.is_key_pressed(KEY_3):
		choose_weapon('bow')

	if Input.is_action_just_pressed("Attack") && can_attack:
		can_attack = false
		attack_timer.start()
		if Global.weapon != Global.Weapon.bow:
			swoosh_audio.play()
			if enemy:
				enemy.damage(Global.DAMAGE * Global.DAMAGE_MULTIPLIER)
				hit_audio.play()
		else:
			can_move = false
			var new_arrow = arrow.instantiate()
			if(get_global_mouse_position().x < $Arrow_Spawn_Point/point.global_position.x):
				change_scale(-1)
			else:
				change_scale(1)
			await get_tree().create_timer(0.5).timeout
			new_arrow.global_position = $Arrow_Spawn_Point/point.global_position
			new_arrow.set_target_location(get_global_mouse_position())
			add_sibling(new_arrow)
			can_move = true

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
		if(footsteps_timer.is_stopped() && is_on_floor()):
			footsteps_timer.start()
			match current_zone:
				'outside':
					grass_audio.play()
				'castle':
					stone_audio.play()
				_:
					grass_audio.play()
		if direction.x:
			change_scale(direction.x)
		if is_on_floor() && !is_dashing:
			anim.play("Running")

		if Input.is_action_pressed("Move_Box") && can_move_box:
			current_speed = 50
			is_moving_box = true

		velocity.x = direction.x * current_speed

		if Input.is_action_just_pressed("Dash") && can_dash && (Global.can_dash_horizontal || Global.can_dash_any_direction):
			dash_time.start()
			dash_cooldown.start()
			normal_col_shape.disabled = true
			dash_col_shape.disabled = false
			can_dash = false
			if(Global.take_less_damage_when_dashing):
				Global.DAMAGE_TAKEN_MULTIPLIER = Global.take_less_damage_when_dashing_multiplier
			if Global.can_dash_any_direction:
				velocity = direction
				velocity = velocity.normalized() * current_speed
			else:
				velocity.x = direction.x * dash_power
				velocity.y = 0
			anim.play("Dashing")
			can_move_also_vertically = false
			is_dashing = true
			await get_tree().create_timer(0.2).timeout
			can_move_also_vertically = true
			current_speed = dash_power
	else:
		if is_on_floor() && !is_dashing:
			anim.play("Idle")
		if !is_dashing:
			velocity.x = move_toward(velocity.x, 0, current_speed)

	if can_move_also_vertically:
		move_and_slide()

	for index in get_slide_collision_count():
		var collision = get_slide_collision(index)
		var body = collision.get_collider()
		if body.is_in_group("Danger"):
			#can_move = false
			#anim.play("Dead")
			Global.player_death()

func choose_weapon(weapon_name : String):
	spear_check.monitoring = false
	sword_check.monitoring = false
	weapon_name = weapon_name.to_lower()
	match weapon_name:
		'spear':
			spear_check.monitoring = true
			Global.weapon = Global.Weapon.spear
			Global.time_between_attacks = Global.spear_time_between_attacks
			Global.DAMAGE = Global.spear_damage
		'sword':
			sword_check.monitoring = true
			Global.weapon = Global.Weapon.sword
			Global.time_between_attacks = Global.sword_time_between_attacks
			Global.DAMAGE = Global.sword_damage
		'bow':
			Global.weapon = Global.Weapon.bow
			Global.time_between_attacks = Global.bow_time_between_attacks
			Global.DAMAGE = Global.bow_damage
	print(weapon_name)
	print(Global.weapon)
	print(Global.DAMAGE)
	attack_timer.set_wait_time(Global.time_between_attacks)

func change_scale(x):
	anim.scale.x = x
	spear_check.scale.x = x
	sword_check.scale.x = x
	$Arrow_Spawn_Point.scale.x = x

func change_zone(zn_name : String):
	current_zone = zn_name

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_dash_time_timeout():
	current_speed = speed
	if(Global.take_less_damage_when_dashing):
		Global.DAMAGE_TAKEN_MULTIPLIER = 1.0
	is_dashing = false
	normal_col_shape.disabled = false
	dash_col_shape.disabled = true

func _on_check_for_box_body_entered(body):
	if body.is_in_group("Box"):
		can_dash = false
		can_move_box = true

func _on_check_for_box_body_exited(body):
	if body.is_in_group("Box"):
		can_dash = true
		can_move_box = false

func _on_spear_attack_check_body_entered(body):
	if(body.has_method('damage')):
		enemy = body
func _on_spear_attack_check_body_exited(_body):
	enemy = null

func _on_sword_attack_check_body_entered(body):
	if(body.has_method('damage')):
		enemy = body
func _on_sword_attack_check_body_exited(_body):
	enemy = null

func _on_time_between_attacks_timeout():
	can_attack = true
