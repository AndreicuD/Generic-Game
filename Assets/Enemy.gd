extends CharacterBody2D

enum State {PASSIVE, ACTIVE}
var state = State.PASSIVE

@export var health = 120.0

var can_move = true
var is_dead = false

var current_speed = 50.0
@export var speed = 50.0
@export var following_speed = 80.0
@export var jump_power = 225.0
@export var gets_stunned_after_lost_player = false
@export var checkpoints = []
var target_checkpoint : Vector2
var curr_check_ind = 0
var player

@onready var cooldown_timer = $Cooldown_Timer
#general cooldown for how much to sit at checkpint
@onready var wait_before_jump_timer = $Wait_Before_Jump_Timer
@onready var change_state_cooldown = $Change_State_Cooldown
@onready var exclamation_mark = $excl_mark

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

@onready var check_for_player_to_follow_left = $Check_For_Player_To_Follow_Left
@onready var check_for_player_to_keep_following_left = $Check_For_Player_To_Keep_Following_Left
@onready var check_for_player_to_follow_right = $Check_For_Player_To_Follow_Right
@onready var check_for_player_to_keep_following_right = $Check_For_Player_To_Keep_Following_Right

@onready var blood : GPUParticles2D = $Blood_Particles

func _ready():
	target_checkpoint = checkpoints[curr_check_ind]
	player = get_tree().get_first_node_in_group('Player')

func damage(val):
	state = State.ACTIVE
	blood.emitting = true
	health = health - val
	anim.rotation = -0.1
	await get_tree().create_timer(0.05).timeout
	anim.rotation = 0
	if(health<=0):
		die()
	current_speed = 0.2 * following_speed
	await get_tree().create_timer(0.1).timeout
	current_speed = following_speed

func die():
	anim.play('dead')
	can_move = false
	is_dead = true
	$CollisionShape2D.set_disabled(true)
	$Dead_Timer.start()
	#Global.has_killed_enemy()

func _physics_process(delta):
	if !is_dead:
		velocity.y += gravity*delta
		velocity.y = clamp(velocity.y, -300, 300)
	velocity.x = 0

	if(can_move):
		if(state == State.PASSIVE):
			current_speed = speed
			target_checkpoint = checkpoints[curr_check_ind]
			if(target_checkpoint.x - global_position.x > 5):
				velocity.x = 1
			elif(target_checkpoint.x - global_position.x < -5):
				velocity.x = -1
			else:
				velocity.x = 0
				anim.play("default")
				can_move = false
				cooldown_timer.start()
				curr_check_ind += 1
				curr_check_ind %= checkpoints.size()
		elif(state == State.ACTIVE):
			target_checkpoint = player.global_position
			if(target_checkpoint.x - global_position.x > 5):
				velocity.x = 1
			elif(target_checkpoint.x - global_position.x < -5):
				velocity.x = -1

	if velocity.x == 1:
		check_for_player_to_follow_right.monitoring = true
		check_for_player_to_keep_following_right.monitoring = true
		check_for_player_to_follow_left.monitoring = false
		check_for_player_to_keep_following_left.monitoring = false
	elif velocity.x == -1:
		check_for_player_to_follow_left.monitoring = true
		check_for_player_to_keep_following_left.monitoring = true
		check_for_player_to_follow_right.monitoring = false
		check_for_player_to_keep_following_right.monitoring = false
	elif velocity.x == 0:
		check_for_player_to_follow_right.monitoring = true
		check_for_player_to_keep_following_right.monitoring = true
		check_for_player_to_follow_left.monitoring = true
		check_for_player_to_keep_following_left.monitoring = true


	if(is_on_wall() && is_on_floor()):
		can_move = false
		wait_before_jump_timer.start()

	velocity.x *= current_speed
	move_and_slide()

func _on_change_state_cooldown_timeout():
	if !is_dead:
		can_move = true
	exclamation_mark.set_visible(false)

func _on_cooldown_timer_timeout():
	if !is_dead:
		can_move = true

func _on_wait_before_jump_timer_timeout():
	if !is_dead:
		can_move = true
	velocity.y -= jump_power

func _on_check_for_player_to_follow_body_entered(body):
	if body.is_in_group("Player") && state != State.ACTIVE:
		can_move = false
		change_state_cooldown.start()
		exclamation_mark.set_visible(true)
		player = body
		state = State.ACTIVE
		current_speed = following_speed

func _on_check_for_player_to_keep_following_body_exited(body):
	if body.is_in_group("Player") && state != State.PASSIVE:
		if (gets_stunned_after_lost_player == true):
			velocity.x = 0
			can_move = false
			cooldown_timer.start()
		state = State.PASSIVE


func _on_dead_timer_timeout():
	self.queue_free()
