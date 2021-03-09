extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var world_data

var tree3mesh = preload("res://GameWorld/Terrain/tree3.obj")

# Called when the node enters the scene tree for the first time.
func _ready():
	multimesh = MultiMesh.new()
	# Set the format first.
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.color_format = MultiMesh.COLOR_NONE
	multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_NONE
	multimesh.mesh = tree3mesh
	# Then resize (otherwise, changing the format is not allowed).
	multimesh.instance_count = 20
	multimesh.visible_instance_count = -1
	
	for x in range(multimesh.instance_count):
#		self.multimesh.set_instance_transform(x, Transform(Basis(), Vector3(0,0,0)))
		var rand_x = rand_range(-0.5, 0.5)
		var rand_z = rand_range(-0.5, 0.5)
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
