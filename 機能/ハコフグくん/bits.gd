extends Node2D
class_name Bits

var bits:Array[Bit]
var own_value:int

signal bit_overflew

class Bit:
	extends Sprite2D
	
	@onready var ONE  = preload("res://機能/ハコフグくん/テクスチャ/イチ.png")
	@onready var ZERO = preload("res://機能/ハコフグくん/テクスチャ/ゼロ.png")
	
	var own_value:bool:
		set(value):
			if not is_node_ready():
				await ready
			if value:
				self.texture = self.ONE
			else:
				self.texture = self.ZERO
			own_value = value

func make_bit(pos:int, value:bool) -> Bit:
	var new:Bit = Bit.new()
	new.z_index = 1
	new.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	new.position.x = get_bit_pos(pos)
	new.own_value = value
	return new

static func value_to_bit_array(value:int) -> Array[bool]:
	var bit_array: Array[bool] = []
	var num = value
	while num > 0:
		if (num & 1) == 1:
			bit_array.append(true)
		else:
			bit_array.append(false)
		num = num >> 1
	return bit_array

func get_bit_pos(pos:int):
	return (get_bitwidth() - pos) * Hakofugu.TILE_PIXEL

func get_bitwidth() -> int:
	return self.bits.size()

func push_bit_front(bit_value:bool) -> void:
	var bit = make_bit(bits.size(), bit_value)
	for b in bits:
		b.position.x += Hakofugu.TILE_PIXEL
	add_child(bit)
	bits.push_front(bit)

func push_bit_back(bit_value:bool) -> void:
	var bit = make_bit(0, bit_value)
	add_child(bit)
	bits.push_back(bit)

func pop_bit_front() -> bool:
	var front = bits[0]
	bits.remove_at(0)
	for b in bits:
		b.position.x -= Hakofugu.TILE_PIXEL
	return front.own_value

func pop_bit_back() -> bool:
	var back = bits[bits.size()-1]
	return back.own_value

func set_bitwidth(width:int) -> void:
	if bits.size() > width:
		for _i in range(bits.size() - width):
			if pop_bit_front():
				bit_overflew.emit()
	else:
		for _i in range(width - bits.size()):
			push_bit_front(false)

func shrink(duration:float) -> void:
	var i:int = 0
	var interval:float = duration / self.bits.size()
	var reversed = bits
	reversed.reverse()
	
	for b in reversed:
		get_tree()\
			.create_timer(i * interval)\
			.timeout\
			.connect(func(): b.visible = false)
		i += 1
	
func expand(duration:float) -> void:
	var i:int = 0
	var interval:float = duration / self.bits.size()
	var reversed = bits
	reversed.reverse()
	
	for b in reversed:
		i += 1
		get_tree()\
			.create_timer(i * interval)\
			.timeout\
			.connect(func(): b.visible = true)

func __set_for_all_bits__(property:String, value:Variant) -> void:
	for b in bits:
		b.set(property, value)
