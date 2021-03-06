extends Node

#type GamePos - offset coords Vector2[int]
#type WorldPos - world coords Vector3

var SoftNoise = load("res://GameWorld/softnoise.gd")

export var WORLD_RADIUS = 24
export var WORLD_RADIUS_FEATHER = 24
export var TERRAIN_HEIGHT_SCALE = 15.0
export var stone_min_angle = PI/8.0

var noise = null

var noises_weight_sum = 0.0
export var noises_scales = PoolRealArray([0.006,0.023,0.124,0.34,0.19,0.53])
var noises_modifiers = PoolVector2Array()

export var forest_noise_scale = 0.75

export(String) var game_seed = null

export(float,0,1) var water_height = 0.41
export(float,0,1) var sand_height = 0.411
export(float,0,1) var grass_height = 0.43
export(float,0,1) var gravel_height = 0.61
export(float,0,1) var snow_height = 0.67

onready var game_space = get_node("/root/GameSpace")

enum cell_type {WATER, SAND, GRASS, STONE, GRAVEL, SNOW}

const xStep = 1.0
const zStep = sqrt(3.0) / 2.0
const up = Vector3(0.0,1.0,0.0)

func _ready():
	if game_seed == null:
		randomize()
	else:
		seed(game_seed.hash())
	noise = SoftNoise.new(game_seed.hash())
	for i in range(noises_scales.size()):
		noises_modifiers.insert(i, Vector2(randf(),randf()))

func get_cells_in_radius(pos, radius):
	return game_space.offset_range(pos, radius)

func get_game_pos(pos):
	return game_space.world_to_offset(pos)

func is_passable(game_pos):
	var impassable = [
		cell_type.SNOW,
		cell_type.STONE,
		cell_type.WATER
	]
	return not impassable.has(get_cell_type(get_world_pos(game_pos)))
	
func is_water(pos):
	if [cell_type.WATER].has(get_cell_type(pos)): return true
	
func get_world_pos(game_pos):
	return game_space.offset_to_world(game_pos)

func get_height(pos):
	var radius = pos.length()
	if radius > WORLD_RADIUS:
		return 0.0
	var sum = 0.0
	var sum_weight = 1.0
	var weight = 1.0
	for i in range(noises_scales.size()):
		#var scale = noises_scales[i]
		var probe = (Vector2(pos.x,pos.z) + noises_modifiers[i]) * noises_scales[i]
		var val = (noise.openSimplex2D(probe.x, probe.y) + 1.0) * 0.5
		val *= weight
		sum += val
		weight = val
		sum_weight += weight
	var world_radius_modifier = ((WORLD_RADIUS - max(radius,WORLD_RADIUS-WORLD_RADIUS_FEATHER)) / WORLD_RADIUS_FEATHER)
	return world_radius_modifier * sum / sum_weight

func is_forest(pos):
	if [cell_type.WATER,cell_type.STONE,cell_type.SNOW,cell_type.SAND].has(get_cell_type(pos)): return false
	var probe = Vector2(pos.x,pos.z) * forest_noise_scale
	var val = (noise.openSimplex2D(probe.x, probe.y) + 1.0) * 0.5
	return val > 0.6

func get_normal(pos):
	var delta = Vector3(0.001,0.0,0.0)
	var p0 = pos + delta
	p0.y = get_terrain_mesh_height(p0)
	var p1 = pos + delta.rotated(up, PI*2/3)
	p1.y = get_terrain_mesh_height(p1)
	var p2 = pos + delta.rotated(up, PI*4/3)
	p2.y = get_terrain_mesh_height(p2)
	return (p1-p0).cross(p2-p0).normalized()

func get_surface_normal(pos):
	var delta = Vector3(0.001,0.0,0.0)
	var p0 = pos + delta
	p0.y = get_surface_height(p0)
	var p1 = pos + delta.rotated(up, PI*2/3)
	p1.y = get_surface_height(p1)
	var p2 = pos + delta.rotated(up, PI*4/3)
	p2.y = get_surface_height(p2)
	return (p1-p0).cross(p2-p0).normalized()

func get_terrain_mesh_height(pos):
	var height = get_height(pos)
	height -= water_height
	height /= 1.0 - water_height
	return height * abs(height) * TERRAIN_HEIGHT_SCALE

func get_surface_height(pos):
	var height = get_terrain_mesh_height(pos)
	return height if height > 0 else 0

func get_cell_type(pos):
	var height = get_height(pos)
	if height>=snow_height: return cell_type.SNOW
	elif height<sand_height: return cell_type.WATER
	if acos(up.dot(get_normal(pos))) > stone_min_angle:
		return cell_type.STONE
	elif height>=gravel_height: return cell_type.GRAVEL
	elif height>=grass_height: return cell_type.GRASS
	elif height>=sand_height: return cell_type.SAND
	else: return cell_type.WATER
