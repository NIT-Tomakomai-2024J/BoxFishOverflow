extends Node2D
class_name Hakofugu

@export_subgroup("依存関係")
@export var wall_layer:TileMapLayer

@onready var visual : Node2D   = $Visual
@onready var body   : Sprite2D = $Visual/Body
@onready var tail   : Sprite2D = $Visual/Tail

const TILE_PIXEL = 16
const HALF_TILE  = 8
const EXPAND_DURATION = 0.25
const MOVE_DURATION = 0.25

@onready var bit:Bits = Bits.new()

var is_moving = false
var is_expanding = false

var is_width_changing = false

func _ready():
	body.add_child(bit)
	bit.set_bitwidth(4)
	change_body_length(bit.get_bitwidth())
	shrink(EXPAND_DURATION)

func _process(_delta):
	# 他のアクション中を実行中は実行しない
	if not is_on_action():
		#--------- 膨らむ / 縮む ---------#
		if Input.is_action_just_pressed("expand"):
			expand(EXPAND_DURATION * bit.get_bitwidth(), bit.get_bitwidth())
		if is_expanding and not Input.is_action_pressed("expand"):
			shrink(EXPAND_DURATION * bit.get_bitwidth())
	
		#--------- 移動 ---------#
		# x、y方向に-1 or 0 or 1移動する移動量を格納
		var movemenet = Vector2i(
			int(Input.get_axis("move_left", "move_right")),
			int(Input.get_axis("move_up", "move_down"))
		)
		# 移動する、かつ衝突しないなら
		if movemenet and not will_collide_on_coords(get_tile_position() + movemenet):
			is_moving = true
			# 現在地から移動官僚予定地まで移動し、移動し終わったら
			# is_movingをfalseにするように予約する
			create_tween().tween_property(
				self, "position", position + Vector2(movemenet * TILE_PIXEL),
				movemenet.length() * MOVE_DURATION
			).finished.connect(func(): is_moving = false)

func change_body_length(length:int):
	body.region_rect.size.x = length * TILE_PIXEL
	body.position.x = (length * TILE_PIXEL) / 2.0 + HALF_TILE
	bit.global_position = visual.global_position + Vector2(TILE_PIXEL, 0)
	tail.position.x = (length + 1) * TILE_PIXEL

func shrink(duration):
	is_width_changing = true
	is_expanding = false
	create_tween()\
		.tween_property(body, "region_rect:size:x", 0,  duration)
	create_tween()\
		.tween_property(body, "position:x", HALF_TILE,  duration)
	create_tween()\
		.tween_property(bit,  "position:x", HALF_TILE,  duration)
	create_tween()\
		.tween_property(tail, "position:x", TILE_PIXEL, duration)\
		.finished\
		.connect(func(): is_width_changing = false)
	bit.shrink(duration)

func expand(duration, length):
	is_width_changing = true
	is_expanding = true
	create_tween()\
		.tween_property(body, "region_rect:size:x", length * TILE_PIXEL,  duration)
	create_tween()\
		.tween_property(body, "position:x", (length * TILE_PIXEL) / 2 + HALF_TILE,  duration)
	create_tween()\
		.tween_property(bit,  "global_position:x", visual.global_position.x + TILE_PIXEL,  duration)
	create_tween()\
		.tween_property(tail, "position:x", (length + 1) * TILE_PIXEL, duration)\
		.finished\
		.connect(func(): is_width_changing = false)
	bit.expand(duration)

func get_tile_position() -> Vector2i:
	return Vector2i(self.position / TILE_PIXEL)

func is_on_action() -> bool:
	return self.is_moving or self.is_width_changing

## ある座標に頭があるとき、Wall Layerと衝突するかを判定する
func will_collide_on_coords(coords:Vector2i):
	var own_width = 2
	if is_expanding:
		own_width += bit.get_bitwidth()
	for i in range(own_width):
		if wall_layer.get_cell_source_id(coords + Vector2i(i, 0)) != -1:
			return true
	return false
