extends RigidBody3D


func set_type(type):
	set_meta("type", type)
	$MeshInstance3D.scale = Vector3.ONE * Global.ball_data[type].size
	$CollisionShape3D.scale = Vector3.ONE * Global.ball_data[type].size
	if type != "golf":
		$MeshInstance3D.material_override.albedo_texture = Global.ball_data[type].texture
	else:
		$MeshInstance3D.material_override.normal_enabled = true
		$MeshInstance3D.material_override.normal_texture = Global.ball_data[type].texture
