# © 2023 Ilya S <ilya.s@fmlht.com>
# https://github.com/ismslv/

@icon("res://animation_nodes/Anim_Rotating.png")
class_name Rotating
extends Animating

@export var enabled = true
@export var speed = 0.1
@export var angles = Vector3(0, 1, 0)
@export var goal = 0.0
@export var loop = true

@onready var parent: Node3D = get_parent()

var start = 0.0
var target = 0.0
var rotating = false
var lerp_val = 0.0

var anim: Tween

func _ready():
	if enabled:
		start_rotation()
	
func _process(delta):
	if rotating:
		if check_limit():
			if loop:
				lerp_val = 0.0
				set_current_axis(start)
			else:
				rotating = false
		else:
			lerp_val += speed * delta
			parent.rotation_degrees = angles * lerp(start, target, lerp_val)

func get_current_axis():
	if angles.x == 1:
		return parent.rotation_degrees.x
	elif angles.y == 1:
		return parent.rotation_degrees.y
	elif angles.z == 1:
		return parent.rotation_degrees.z

func set_current_axis(angle):
	if angles.x == 1:
		parent.rotation_degrees.x = angle
	elif angles.y == 1:
		parent.rotation_degrees.y = angle
	elif angles.z == 1:
		parent.rotation_degrees.z = angle
	
func check_limit():
	if start < goal:
		return get_current_axis() >= target
	else:
		return get_current_axis() <= target

func start_rotation():
	lerp_val = 0.0
	target = goal
	start = get_current_axis()
	rotating = true
