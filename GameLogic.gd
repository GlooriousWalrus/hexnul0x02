extends Node

export(NodePath) var selection_node
onready var selection = get_node(selection_node)
export(NodePath) var world_data_node
onready var world_data = get_node(world_data_node)

var Wagon = preload("res://GameWorld/Units/Wagon.tscn")
var House = preload("res://GameWorld/Places/House.tscn")

signal change_mode(mode)
signal selected(object)

enum Mode {MODE_IDLE,MODE_SELECT,MODE_PLACE,MODE_MOVE}
export(Mode) var mode = Mode.MODE_IDLE setget set_mode

func set_mode(val):
	mode = val
	emit_signal("change_mode", mode)

export(NodePath) var places_node
onready var places = get_node(places_node)
export(NodePath) var units_node
onready var units = get_node(units_node)

enum ObjectType {OBJECT_UNIT, OBJECT_PLACE}

var selected = null
var selected_type = ObjectType.OBJECT_UNIT

func select(object, type):
	selected = object
	selected_type = type
	emit_signal("selected", object)
	
export(ObjectType) var place_mode = ObjectType.OBJECT_UNIT
var PlaceObjectClass = Wagon

func set_place_mode(pmode, ObjectClass):
	place_mode = pmode
	PlaceObjectClass = ObjectClass

func _on_GameWorld_select(pos):
	match(mode):
		Mode.MODE_SELECT:
			var sel = units.select(pos)
			if sel != null:
				print("select unit ", sel)
				select(sel, ObjectType.OBJECT_UNIT)
				return
			sel = places.select(pos)
			if sel != null:
				print("select place ", sel)
				select(sel, ObjectType.OBJECT_PLACE)
				return
			select(null,null)
		Mode.MODE_PLACE:
			if units.map.has(pos) or places.map.has(pos):
				return
			match(place_mode):
				ObjectType.OBJECT_UNIT:
					units.place_unit(PlaceObjectClass, pos)
					var unit = units.select(pos)
					select(unit, ObjectType.OBJECT_UNIT if unit else null)
				ObjectType.OBJECT_PLACE:
					if world_data.is_forest(world_data.get_world_pos(pos)):
						return
					places.place_place(PlaceObjectClass, pos)
					var place = places.select(pos)
					select(place, ObjectType.OBJECT_PLACE if place else null)
		Mode.MODE_MOVE:
			if (selected_type == ObjectType.OBJECT_UNIT) and selected:
				if units.move_unit(selected, pos):
					set_mode(Mode.MODE_SELECT)
					select(units.select(pos), ObjectType.OBJECT_UNIT)

func _on_GameWorld_change_mode(mode):
	if mode==Mode.MODE_MOVE and selected and selected_type!=ObjectType.OBJECT_UNIT: return
	set_mode(mode)

func _on_GameWorld_change_place_mode(mode, ObjectClass):
	set_place_mode(mode, ObjectClass)

func _on_Select_pressed():
	set_mode(Mode.MODE_SELECT)


func _on_Move_pressed():
	if selected and selected_type==ObjectType.OBJECT_UNIT:
		set_mode(Mode.MODE_MOVE)


func _on_Units_mode_wagon():
	set_place_mode(ObjectType.OBJECT_UNIT, Wagon)
	set_mode(Mode.MODE_PLACE)

func _on_Places_mode_house():
	set_place_mode(ObjectType.OBJECT_PLACE, House)
	set_mode(Mode.MODE_PLACE)
