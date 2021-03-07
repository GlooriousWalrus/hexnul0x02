extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var world_data

# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(6):
		var rand_x = rand_range(-0.5, 0.5)
		var rand_z = rand_range(-0.5, 0.5)
		print(rand_x)
		self.multimesh.set_instance_transform(x, 
			Transform(
				Basis(), 
				Vector3(
					rand_x,
					world_data.get_terrain_mesh_height(
						to_global(
							self.multimesh.get_instance_transform(x).origin + 
								Vector3(rand_x,
										0,
										rand_z
								)
						)
					),
					rand_z
				)
			)
		)
#		print(world_data.get_terrain_mesh_height(to_global(self.multimesh.get_instance_transform(x).origin)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
