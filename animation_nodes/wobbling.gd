# © 2023 Ilya S <ilya.s@fmlht.com>
# https://github.com/ismslv/

@icon("res://animation_nodes/Anim_Wobbling.png")
class_name Wobbling
extends Animating

@export var wobble_enabled = true
@export var wobble_speed = 100.0
@export var wobble_axis = Vector3(0, 1, 0)
@export var wobble_size = 0.0

@onready var parent: Node3D = get_parent()

var wobble_start: Vector3
var wobble_target: Vector3
var anim: Tween

func _ready():
	if wobble_enabled:
		wobble_start = parent.position
		wobble_target = wobble_start
		start_wobble()
		
		
func start_wobble():
	if wobble_target == wobble_start:
		wobble_target = wobble_start + wobble_axis * wobble_size
	else:
		wobble_target = wobble_start
		
	anim = create_tween()
	anim.tween_property(parent, "position", wobble_target, wobble_speed)

func _process(_delta):
	if wobble_enabled:
		if parent.position == wobble_target:
			anim.stop()
			start_wobble()
