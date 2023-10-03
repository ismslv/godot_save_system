# © 2023 Ilya S <ilya.s@fmlht.com>
# https://github.com/ismslv/

extends CharacterBody3D

@export var speed: float = 10 # m/s
@export var acceleration: float = 100 # m/s^2

var move_dir: Vector2 # Input direction for movement
var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera: Camera3D = get_node("/root/main/Camera3D")
var is_walking = false

var charge = 100.0
var batteries = 0

func _process(delta):
	if is_walking:
		set_charge(charge - speed * delta)

func save_data(data: SaveGame):
	data.player_pos = position
	data.player_rot = $godotbot.rotation
	data.charge_level = charge
	data.inventory.batteries = batteries
	return data

func load_data(data: SaveGame):
	position = data.player_pos
	set_charge(data.charge_level)
	set_inventory(data.inventory.batteries)
	$godotbot.rotation = data.player_rot

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_forward") || Input.is_action_just_pressed("move_backwards") || Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_right"):
		is_walking = true
		$godotbot/AnimationPlayer.speed_scale = speed
		$godotbot/AnimationPlayer.play("godotbot_walk/Walk")
	if event.is_released():
		if not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_backwards") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			is_walking = false
			$godotbot/AnimationPlayer.speed_scale = 1
			$godotbot/AnimationPlayer.play("godotbot_idle/Idle1")


func _physics_process(delta: float) -> void:
	velocity = _walk(delta) + _gravity(delta)
	$LookTarget.position = lerp($LookTarget.position, walk_vel, delta * speed * 8)
	if is_walking:
		$godotbot.look_at($LookTarget.global_position, Vector3.UP)
	move_and_slide()


func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel
	
func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func set_charge(value):
	charge = clamp(value, 1, 100)
	%ChargeSlider.value = value

func set_inventory(value):
	batteries = value
	%BatteriesField.text = "BATTERIES: " + str(value)

func consume_battery():
	set_charge(charge + 10)
	set_inventory(batteries + 1)
