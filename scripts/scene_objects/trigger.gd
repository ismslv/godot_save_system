extends Area3D

signal on_trigger

func _ready():
	pass


func activate():
	$CSGCylinder3D.position = Vector3(0, -0.02, 0)
	$CSGCylinder3D.material.albedo_color = Color.GREEN
	emit_signal("on_trigger")
	

func deactivate():
	$CSGCylinder3D.position = Vector3(0, 0.02, 0)
	$CSGCylinder3D.material.albedo_color = Color.WHITE


func _on_body_entered(body):
	if body.name == "Player":
		activate()


func _on_body_exited(body):
	if body.name == "Player":
		deactivate()
