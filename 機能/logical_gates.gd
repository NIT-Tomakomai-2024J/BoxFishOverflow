extends TileMapLayer
class_name LogicalGates

enum GateKind {
	OR, AND, NOT,
	NOR, NAND,
	XOR
}

class Option:
	var some
	var is_some:bool
	
	func unwrap():
		if self.is_some:
			return self.some
		else:
			printerr("Unwraped on none value.")
			return null
	
	static func Some(value) -> Option:
		var opt = Option.new()
		opt.some = value
		opt.is_some = true
		return opt
	
	static func None() -> Option:
		var opt = Option.new()
		opt.is_some = false
		return opt

class LogicalGate:
	var gate_kind:GateKind
	var bits:Array[bool]
	var head_pos:Vector2i

func is_tile_0_or_1(coords:Vector2i) -> bool:
	return get_id_as_bool(coords).is_some

func get_id_as_bool(coords:Vector2i) -> Option:
	match self.get_cell_atlas_coords(coords):
		Vector2i(0, 0):
			return Option.Some(true)
		Vector2i(1, 0):
			return Option.Some(false)
		_:
			return Option.None()

func get_head_kind(coords:Vector2i) -> Option:
	match self.get_cell_atlas_coords(coords):
		Vector2i(0, 2):
			return Option.Some(GateKind.OR)
		Vector2i(0, 1):
			return Option.Some(GateKind.AND)
		_:
			return Option.None()

func get_bits_from(from:Vector2i) -> Option:
	var o = 0
	var bits:Array[bool]
	
	while true:
		var bit = get_id_as_bool(from + Vector2i(o, 0))
		if not bit.is_some:
			break
		else:
			bits.push_back(bit.unwrap())
		o += 1
	return Option.Some(bits)

### It return Option wrapped Vector2i
func get_bits_left_limit(coords:Vector2i) -> Option:
	if not is_tile_0_or_1(coords):
		return Option.None()
	var i = 0
	while is_tile_0_or_1(coords - Vector2i(i, 0)):
		i += 1
	var left_limit = coords - Vector2i(i, 0)
	return Option.Some(left_limit)

func get_logical_gate(coords:Vector2i) -> Option:
	# そのタイルが0か1なら
	if is_tile_0_or_1(coords):
		var from = get_bits_left_limit(coords)
		if not from.is_some:
			return Option.None()
		from = from.unwrap()
		var bits = get_bits_from(from + Vector2i(1, 0))
		if not bits.is_some:
			return Option.None()
		bits = bits.unwrap()
		
		var head_kind = get_head_kind(from)
		if not head_kind.is_some:
			printerr(
				"A headless logical gate found.\n	Detail :\n	Head Coords -> ",
				from, "\n	Atlus Coords -> ", get_cell_atlas_coords(from)
			)
			return Option.None()
		
		var lgate = LogicalGate.new()
		lgate.bits = bits
		lgate.gate_kind = head_kind.unwrap()
		lgate.head_pos = from + Vector2i(1, 0)
		
		return Option.Some(lgate)
	elif get_head_kind(coords).is_some:
		var from = coords + Vector2i(1, 0)
		var bits = get_bits_from(from)
		if not bits.is_some:
			return Option.None()
		bits = bits.unwrap()
		
		var head_kind = get_head_kind(coords).unwrap()
		
		var lgate = LogicalGate.new()
		lgate.bits = bits
		lgate.gate_kind = head_kind
		lgate.head_pos = from + Vector2i(1, 0)
		
		return Option.Some(lgate)
	else:
		return Option.None()
