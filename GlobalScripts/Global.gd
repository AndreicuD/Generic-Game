extends Node

var scene_manager

# PLAYER THINGS

enum Weapon {spear, sword, bow}
var weapon = Weapon.spear

var cards = []

var HEALTH = 100
var MAX_HEALTH = 100

var DAMAGE = 10
var DAMAGE_TAKEN_MULTIPLIER = 1.0
var DAMAGE_MULTIPLIER = 1.0
var CURRENT_DAMAGE_MULTIPLIER = 1.0
var time_between_attacks = 0.1

var spear_damage = 20
var spear_time_between_attacks = 0.2
var sword_damage = 50
var sword_time_between_attacks = 0.4
var bow_damage = 25
var bow_time_between_attacks = 1

var basic_enemy_damage = 20
var bow_enemy_damage = 30

var HEAL_MULTIPLIER = 0.0

var CURRENCY = 0
var sword_cost = '0'
var bow_cost = '100'
var spear_cost = '200'

var is_player_dead : bool = false
var can_damage_player : bool = true

var spawn_point = Vector2(0,0)

var default_max_health = 100
var default_spawn_point = Vector2(0,0)

var can_dash_horizontal : bool = true
var can_dash_any_direction : bool = false
var dash_ability_cost = '50'
var take_less_damage_when_dashing : bool = false
var take_less_damage_when_dashing_multiplier = 0.5
var less_damage_when_dashing_cost = '75'
var damage_when_dashing : bool = false
var damage_when_dashing_multiplier = 0.5
var do_damage_when_dashing_cost = '75'

var damage_level_1_upgrade : bool = false
var damage_level_1_upgrade_multiplier = 1.5
var dmg_lvl1_cost = '65'
var damage_level_2_upgrade : bool = false
var damage_level_2_upgrade_multiplier = 2
var dmg_lvl2_cost = '150'

var heal_when_kill_level_1 : bool = false
var heal_level_1_upgrade = 20.0
var heal_lvl1_cost = '75'
var heal_when_kill_level_2 : bool = false
var heal_level_2_upgrade = 30.0
var heal_lvl2_cost = '150'

#----------------------------------------------------------

var current_level : String
var has_save_file : bool = false

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#load_game()
	scene_manager = get_tree().get_first_node_in_group("scene_manager")

func _physics_process(_delta):
	pass

#----------------------------------------------------------

#https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
#look at this if you have problems
func save_game():
	var save_game_file = FileAccess.open("res://savegame.save", FileAccess.WRITE)

	var max_health_dic = {
		"what_is_saved" : "max_health",
		"amount" : MAX_HEALTH
	}

	var spawn_point_dic = {
		"what_is_saved" : "spawn_point",
		"position" : var_to_str(get_spawn_point())
	}

	var max_health_info = JSON.stringify(max_health_dic)
	save_game_file.store_line(max_health_info)
	var spawn_point_info = JSON.stringify(spawn_point_dic)
	save_game_file.store_line(spawn_point_info)

func load_game():
	if not FileAccess.file_exists("res://savegame.save"):
		return #error, file wasn't found

	var save_game_file = FileAccess.open("res://savegame.save", FileAccess.READ)
	has_save_file = true

	#citeste fiecare linie
	while save_game_file.get_position() < save_game_file.get_length():
		var json_string = save_game_file.get_line()
		var json = JSON.new()
		# Creates the helper class to interact with JSON

		var parse_result = json.parse(json_string)
		#we parse and verify if it's ok
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		#read that line
		var node_data = json.get_data()

		#verify what it is
		match node_data["what_is_saved"]:
			"spawn_point":
				set_spawn_point(str_to_var(node_data["position"]))
			"max_health":
				set_max_health(float(node_data["amount"]))

func delete_save():
	var dir = DirAccess.open("res://")
	if FileAccess.file_exists("res://savegame.save"):
		dir.remove("res://savegame.save")
	MAX_HEALTH = default_max_health
	spawn_point = default_spawn_point
	has_save_file = false

#----------------------------------------------------------

#in level
func reset_player_position_and_health():
	var Player = get_tree().get_first_node_in_group("Player")
	Player.position = default_spawn_point
	#if(Player.is_gravity_reversed):
	#	Player.gravity_reverse()
	HEALTH = MAX_HEALTH

func reset_player_to_checkpoint():
	var Player = get_tree().get_first_node_in_group("Player")
	Player.position = spawn_point
	HEALTH = MAX_HEALTH

func player_death():
	#var animator : AnimationPlayer = get_tree().get_first_node_in_group('screen_animator')
	#animator.play_transition("Death_Fade_In")
	scene_manager.change_level('Main_Room')
	#await get_tree().create_timer(2).timeout
	#animator.play_transition("Death_Fade_Out")

#----------------------------------------------------------

func set_spawn_point(new_point):
	spawn_point = new_point
	save_game()

func get_spawn_point():
	return spawn_point

#----------------------------------------------------------

func set_health(health):
	HEALTH = health

func set_max_health(health):
	MAX_HEALTH = health

func get_health():
	return HEALTH

func get_max_health():
	return MAX_HEALTH

func heal_health(healAmount):
	HEALTH += healAmount

func take_damage(damage):
	HEALTH -= damage

#----------------------------------------------------------

func has_killed_enemy(enemy_class : String):
	enemy_class = enemy_class.to_lower()
	var val
	if(heal_when_kill_level_1 or heal_when_kill_level_2):
		HEALTH += Global.HEAL_MULTIPLIER/100 * MAX_HEALTH
	match enemy_class:
		'basic':
			val = randi_range(5, 10)
			#intre 5 si 10 banuti
		'bow':
			val = randi_range(10, 20)
			#intre 10 si 20
		_:
			val =  randi_range(20, 30)
			#intre 20 si 30
	CURRENCY += val
