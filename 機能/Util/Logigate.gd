class_name Logigate

enum GateKind {
	OR, AND, NOT,
	NOR, NAND,
	XOR,
	COLGATE
}

var gate_kind:GateKind
var bits:Array[bool]
var head_pos:Vector2i

func get_as_value():
	var reversed = bits
	bits.reverse()
	var i = 1
	var result = 0
	
	for b in reversed:
		if b:
			result += i
		i = i << 1
	
	return result

func get_as_str() -> String:
	var res = ""
	for b in self.bits:
		if b:
			res += "1"
		else:
			res += "0"
	return res

func inspect() -> String:
	var head:String
	var tail:String
	match gate_kind:
		GateKind.OR:
			head = "|"
			tail = "("
		GateKind.AND:
			head = "&"
			tail = "]"
		GateKind.NOT:
			head = "~"
			tail = "]"
		GateKind.NOR:
			head = "↓"
			tail = "("
		GateKind.NAND:
			head = "↑"
			tail = "]"
		GateKind.XOR:
			head = "^"
			tail = "("
	return "(" + head + " " + get_as_str() + " " + tail
