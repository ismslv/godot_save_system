extends Resource

class_name SaveGame

@export var player_pos: Vector3
@export var player_rot: Vector3
@export var charge_level: float
@export var inventory = {
	"batteries" = 0
}
@export var transforms = []
@export var random_fruit = {
	"seed" = 0,
	"state" = 0,
	"last_generated" = 0
}
@export var random_balls = {
	"seed" = 0,
	"state" = 0
}
