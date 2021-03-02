extends Spatial

var GameLogicClass = load("res://GameLogic.gd")

export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

onready var game_space = get_node("/root/GameSpace")
onready var pathfinder = $Selection.get_node("Pathfinder")

var Wagon = load("res://GameWorld/Units/Wagon.tscn")
var House = load("res://GameWorld/Places/House.tscn")

signal change_mode(mode)
signal change_place_mode(mode,ObjectClass)
signal select(game_pos)

func _unhandled_input(event):
	match event.get_class():
		"InputEventMouseButton": _mouse_button(event)
		"InputEventMouseMotion": _mouse_motion(event)

func _unhandled_key_input(event):
	match event.scancode:
		KEY_P: emit_signal("change_mode", GameLogicClass.Mode.MODE_PLACE)
		KEY_W:
			emit_signal("change_place_mode", GameLogicClass.ObjectType.OBJECT_UNIT, Wagon)
			emit_signal("change_mode", GameLogicClass.Mode.MODE_PLACE)
		KEY_H:
			emit_signal("change_place_mode", GameLogicClass.Mode.OBJECT_PLACE, House)
			emit_signal("change_mode", GameLogicClass.Mode.MODE_PLACE)
		KEY_M: emit_signal("change_mode", GameLogicClass.Mode.MODE_MOVE)
		KEY_S: emit_signal("change_mode", GameLogicClass.Mode.MODE_SELECT)
		KEY_ESCAPE: emit_signal("change_mode", GameLogicClass.Mode.MODE_IDLE)

func _mouse_button(event):
	match event.button_index:
		BUTTON_WHEEL_UP:
			$GameCamera.move_camera($GameCamera.camera_movement.CAM_LO)
		BUTTON_WHEEL_DOWN:
			$GameCamera.move_camera($GameCamera.camera_movement.CAM_HI)
		BUTTON_LEFT:
			if !event.is_pressed(): emit_signal("select", get_cell_on_hover())

func _mouse_motion(event):
	if event.button_mask & BUTTON_MASK_RIGHT:
		var relative = event.relative
		$GameCamera.move(relative)
	elif event.button_mask & BUTTON_MASK_MIDDLE:
		if event.relative.x > 0:
			$GameCamera.move_camera($GameCamera.camera_movement.CAM_TURN_LEFT)
		else:
			$GameCamera.move_camera($GameCamera.camera_movement.CAM_TURN_RIGHT)
	else:
		$Hover.set_game_pos(get_cell_on_hover())

var ray_length = 100.0
func get_cell_on_hover():
	var mouse_pos = get_viewport().get_mouse_position()
	var pos2d = null
	var from = $GameCamera.project_ray_origin(mouse_pos)
	var to = from + $GameCamera.project_ray_normal(mouse_pos) * ray_length
	var directState = PhysicsServer.space_get_direct_state(self.get_world().get_space())
	var result = directState.intersect_ray(from, to, [], 0x7FFFFFFF, true, true)
#	print(result.keys())
#	draw_line(from, to)
	if result.has("position"):
		pos2d = world_data.get_game_pos(result["position"])
	return pos2d

#
#func draw_line(start, end):
#	$ImmediateGeometry.clear()
#	$ImmediateGeometry.begin(Mesh.PRIMITIVE_LINES)
#	$ImmediateGeometry.add_vertex(start)
#	$ImmediateGeometry.add_vertex(end)
#	$ImmediateGeometry.end()
