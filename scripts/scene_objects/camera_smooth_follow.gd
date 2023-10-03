extends Node

@export var target: Node3D
@export var delay: float = 1
@onready var camera: Camera3D = get_parent()

var offset: Vector3

func _ready():
	set_target(target)

func _process(delta):
	if target != null:
		camera.position = lerp(camera.position, target.position - offset, delta * delay)
		
func set_target(obj):
	target = obj
	offset = target.position - camera.position
