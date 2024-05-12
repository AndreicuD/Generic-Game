extends CharacterBody2D

enum State {PASSIVE, ACTIVE}
var state = State.PASSIVE

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

func _ready():
	target_checkpoint = checkpoints[curr_check_ind]

func _physics_process(delta):
	velocity.y += gravity*delta
	velocity.y = clamp(velocity.y, -300, 300)

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
			current_speed = following_speed
			target_checkpoint = player.position
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

	#for index in get_slide_collision_count():
	#	var collision = get_slide_collision(index)
	#	var body = collision.get_collider()
	#	if body.is_in_group("Danger"):
	#		#can_move = false
	#		#anim.play("Dead")
	#		Global.player_death()

func _on_change_state_cooldown_timeout():
	can_move = true
	exclamation_mark.set_visible(false)

func _on_cooldown_timer_timeout():
	can_move = true

func _on_wait_before_jump_timer_timeout():
	can_move = true
	velocity.y -= jump_power

func _on_check_for_player_to_follow_body_entered(body):
	if body.is_in_group("Player") && state != State.ACTIVE:
		can_move = false
		change_state_cooldown.start()
		exclamation_mark.set_visible(true)
		player = body
		state = State.ACTIVE

func _on_check_for_player_to_keep_following_body_exited(body):
	if body.is_in_group("Player") && state != State.PASSIVE:
		if (gets_stunned_after_lost_player == true):
			velocity.x = 0
			can_move = false
			cooldown_timer.start()
		state = State.PASSIVE