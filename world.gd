extends Node2D
class_name World

@export var tilemap:TileMapLayer
@export var logical_gates:Array[LogicalGate]

func does_tile_exists(coords:Vector2):
	var icoords = Vector2i(coords / 16)
	var tmp = tilemap.get_cell_source_id(icoords) != -1
	for gate in logical_gates:
		var origin = int(gate.global_position.x / 16)
		tmp = tmp or ((origin <= icoords.x) or (icoords.x <= origin + gate.length))
	return tmp
