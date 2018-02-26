extends Spatial

var Cell = preload("res://GameWorld/Terrain/Cell.gd")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var light = get_node("SpotLight")

export(float,1.0,10.0) var light_height = 3.0
export(Material) var material = null

enum HoverState {
	STATE_HOVER,
	STATE_MOVE_PASSABLE,
	STATE_MOVE_IMPASSABLE,
	STATE_PLACE_UNIT
}

var STATE_COLORS = {
	STATE_HOVER: Color("#c3cfb2"),
	STATE_MOVE_PASSABLE: Color("#23fdf2"),
	STATE_MOVE_IMPASSABLE: Color("#ed6d35"),
	STATE_PLACE_UNIT: Color("#6dad35")
}
export(HoverState) var state = STATE_HOVER setget set_state
var cell = null

func set_state(val):
	if val: state = val

func _ready():
	cell = Cell.new(world_data, material)
	cell.translation.y = 0.01
	add_child(cell)
	light.translation.y = light_height + world_data.get_terrain_mesh_height(self.translation)

func update():
	light.light_color = STATE_COLORS[state]
	material.set_shader_param("albedo", STATE_COLORS[state])
	cell.update_shape()