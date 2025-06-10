extends Node2D
class_name Hakofugu

@onready var visual : Node2D   = $Visual
@onready var body   : Sprite2D = $Visual/Body
@onready var tail   : Sprite2D = $Visual/Tail

const TILE_PIXEL = 16
const HALF_TILE  = 8
const EXPAND_DURATION = 1

@onready var bit:Bits = Bits.new()

func change_body_length(length:int):
	body.region_rect.size.x = length * TILE_PIXEL
	body.position.x = (length * TILE_PIXEL) / 2 + HALF_TILE
	bit.global_position = visual.global_position + Vector2(TILE_PIXEL, 0)
	tail.position.x = (length + 1) * TILE_PIXEL

func _ready():
	body.add_child(bit)
	bit.set_bitwidth(4)
	change_body_length(bit.get_bitwidth())
	shrink(EXPAND_DURATION)

func _process(delta):
	if Input.is_action_just_pressed("expand"):
		expand(EXPAND_DURATION, bit.get_bitwidth())
	if Input.is_action_just_released("expand"):
		shrink(EXPAND_DURATION)

func shrink(duration):
	create_tween().tween_property(body, "region_rect:size:x", 0,  duration)
	create_tween().tween_property(body, "position:x", HALF_TILE,  duration)
	create_tween().tween_property(bit,  "position:x", HALF_TILE,  duration)
	create_tween().tween_property(tail, "position:x", TILE_PIXEL, duration)
	bit.shrink(duration)

func expand(duration, length):
	create_tween().tween_property(body, "region_rect:size:x", length * TILE_PIXEL,  duration)
	create_tween().tween_property(body, "position:x", (length * TILE_PIXEL) / 2 + HALF_TILE,  duration)
	create_tween().tween_property(bit,  "global_position:x", visual.global_position.x + TILE_PIXEL,  duration)
	create_tween().tween_property(tail, "position:x", (length + 1) * TILE_PIXEL, duration)
	bit.expand(duration)
