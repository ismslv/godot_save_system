# © 2023 Ilya S <ilya.s@fmlht.com>
# https://github.com/ismslv/

extends Node

var random_fruit = RandomNumberGenerator.new()
var random_balls = RandomNumberGenerator.new()
var last_generated_fruit = 0

@onready var screen_fruit: Sprite3D = $FruitGenerator/FruitScreen

func _ready():
	## LOADING DATA
	# If singleton has preloaded static save data, apply it to the scene
	if SaveManager.loaded_data != null:
		load_data(SaveManager.loaded_data)
		# Empty static data
		SaveManager.loaded_data = null
	else:
		random_fruit.seed = random_fruit.randi() % 1000
		random_balls.seed = random_balls.randi() % 1000
		_on_trigger_random()
	
	# Try to load config file
	# If config file does not exist, load default values
	if SaveManager.config_load() != OK:
		SaveManager.config_load(SaveManager.file_config_default)
	
	## LOCAL SCENE STUFF
	# Show current seeds on generator labels
	$FruitGenerator/Label3D2.text = "seed = " + str(random_fruit.seed)
	$BallDispenser/Label3D2.text = "seed = " + str(random_balls.seed)
	# Start letter animation
	$LettersPusher.apply_impulse(Vector3.BACK * 3)

## SAVES

# Collect the data from the scene
func save_data(data: SaveGame):
	#Collect data from the player node
	data = $Player.save_data(data)
	
	# Get all nodes from the special group
	var transforms = get_tree().get_nodes_in_group("save_transform")
	for t in transforms:
		var t_data = {
			"name": t.name,
			"pos": t.position,
			"rot": t.rotation,
			"spawned": false
		}
		# Check if node was spawned
		# so that loader could respawn it
		if t.has_meta("type"):
			t_data.spawned = true
			t_data.type = t.get_meta("type")
		data.transforms.append(t_data)
		
	# Save RNG values
	data.random_fruit.seed = random_fruit.seed
	data.random_fruit.state = random_fruit.state
	data.random_balls.seed = random_balls.seed
	data.random_balls.state = random_balls.state
	data.random_fruit.last_generated = last_generated_fruit
	
	return data

# Apply loaded data to the scene
func load_data(data: SaveGame):
	$Player.load_data(data)
	
	var transforms = get_tree().get_nodes_in_group("save_transform")
	for d in data.transforms:
		if d.spawned == false:
			# Apply to preloaded objects
			for t in transforms:
				if t.name == d.name:
					if t is RigidBody3D:
						t.linear_velocity = Vector3.ZERO
						t.angular_velocity = Vector3.ZERO
					t.position = d.pos
					t.rotation = d.rot
		else:
			# Spawn a new object
			dispense_object(d.type, d.pos, d.rot)
	
	# Set up random number generators
	random_fruit.seed = data.random_fruit.seed
	random_fruit.state = data.random_fruit.state
	last_generated_fruit = data.random_fruit.last_generated
	render_fruit(last_generated_fruit)
	random_balls.seed = data.random_balls.seed
	random_balls.state = data.random_balls.state

## SCENE-RELATED METHODS

func _on_trigger_random():
	var r = random_fruit.randi() % 12
	while r == last_generated_fruit:
		r = random_fruit.randi() % 12
	last_generated_fruit = r
	render_fruit(last_generated_fruit)

func _on_trigger_dispenser():
	var type = Global.ball_types[random_balls.randi_range(0, 4)]
	dispense_object(type)
	
func turn_cannon(angle, anim):
	if anim:
		$BallDispenser/SourcePoint/Rotating.goal = -angle
		$BallDispenser/SourcePoint/Rotating.start_rotation()
	else:
		$BallDispenser/SourcePoint.rotation_degrees = Vector3(0, -angle, 0)

func dispense_object(type, pos = null, rot = null):
	var obj = load("res://objects/ball.tscn").instantiate()
	add_child(obj)
	obj.set_type(type)
	if pos == null:
		obj.position = $BallDispenser/SourcePoint/Source.global_position
		obj.apply_impulse($BallDispenser/SourcePoint/Source.global_transform.basis.y * 6)
	else:
		obj.position = pos
		obj.rotation = rot

@warning_ignore("integer_division")
func render_fruit(val: int):
	var coords = Vector2i(val % 4, val/4)
	screen_fruit.texture.region = Rect2(coords.x * 512, coords.y * 512, 512, 512)
	pass

## CONFIGS

# Applying configs to the scene
# and displaying the values on UI elements
# Normally it would be two separate processes,
# as settings UI would be in the menu scene
func configs_load():
	$Player.speed = SaveManager.config.get_value("Gameplay", "player_speed", 1.5)
	%SpeedSlider.value = $Player.speed
	var cannon_angle = SaveManager.config.get_value("Gameplay", "cannon_angle", 0.0)
	%CannonSlider.value = cannon_angle
	turn_cannon(cannon_angle, false)
	var aa_value = SaveManager.config.get_value("Graphics", "antialiasing", 0)
	RenderingServer.viewport_set_screen_space_aa(get_tree().get_root().get_viewport_rid(), aa_value)
	%FieldAA.set_pressed_no_signal(aa_value)
	var ao_value = SaveManager.config.get_value("Graphics", "occlusion", false)
	$Camera3D.environment.ssao_enabled = ao_value
	%FieldAO.set_pressed_no_signal(ao_value)

# Saving configs to persistent variable
# Just collecting data from objects and UI
# Normally the most of the data will be just stored in the variable
func configs_save():
	SaveManager.config.set_value("Gameplay", "player_speed", $Player.speed)
	SaveManager.config.set_value("Gameplay", "cannon_angle", %CannonSlider.value)
	SaveManager.config.set_value("Graphics", "antialiasing", 1 if %FieldAA.toggle_mode else 0)
	SaveManager.config.set_value("Graphics", "occlusion", %FieldAO.toggle_mode)
	SaveManager.config_save()

## INPUT

# Waiting for F5-F6 buttons
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("quick_save"):
		SaveManager.game_save("test_save")
	elif Input.is_action_just_released("quick_load"):
		SaveManager.game_load("test_save")

# Save button
# It could open an UI to enter a savegame name instead
func _on_button_save():
	SaveManager.game_save("test_save")

# Load button
# It could be disabled if there are no save files
func _on_button_load():
	SaveManager.game_load("test_save")
	

func _on_speed_slider(_value_changed):
	$Player.speed = %SpeedSlider.value


func _on_cannon_angle_slider(_value_changed):
	var angle = %CannonSlider.value
	turn_cannon(angle, true)


func _on_field_aa_toggled(button_pressed):
	var value = Viewport.SCREEN_SPACE_AA_FXAA if button_pressed else 0
	RenderingServer.viewport_set_screen_space_aa(get_tree().get_root().get_viewport_rid(), value)


func _on_field_ao_toggled(button_pressed):
	$Camera3D.environment.ssao_enabled = button_pressed


func _on_button_save_configs():
	configs_save()


func _on_button_reset_configs():
	SaveManager.config_load(SaveManager.file_config_default)
	SaveManager.config_save()
