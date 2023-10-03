extends RigidBody3D


func _on_body_entered(body):
	if body.name == "Player":
		%Player.consume_battery()
		hide()
		queue_free()
