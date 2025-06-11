extends Node2D
class_name Hakofugu

@export_subgroup("依存関係")
@export var wall_layer:TileMapLayer
@export var gate_layer:LogicalGates

@onready var visual : Node2D   = $Visual
@onready var head   : Sprite2D = $Visual/Head
@onready var body   : Sprite2D = $Visual/Body
@onready var tail   : Sprite2D = $Visual/Tail

const TILE_PIXEL = 16
const HALF_TILE  = 8
const EXPAND_DURATION = 0.1
const MOVE_DURATION = 0.25
const GATE_OVER_DURATION = 0.25

@onready var bit:Bits = Bits.new()

@onready var shrinked_face  = preload("res://機能/ハコフグくん/テクスチャ/ハコフグくん_頭.png")
@onready var expanded_face  = preload("res://機能/ハコフグくん/テクスチャ/ハコフグくん_頭_膨らむ.png")
@onready var surprised_face = preload("res://機能/ハコフグくん/テクスチャ/ハコフグくん_頭_驚く.png")

signal moved(coords:Vector2i)

var is_moving = false
var is_expanding = false

var is_width_changing = false

func _ready():
	visual.add_child(bit)
	bit.set_bitwidth(4)
	change_body_length(bit.get_bitwidth())
	shrink(EXPAND_DURATION)
	moved.connect(_on_moved)

func _process(_delta):
	#-------- メインの処理 -------#
	# 上にあるほど優先度が高くなる
	# とくにhandle_logical_gateの優先度は
	# handle_movementより高くないとおかしくなるので注意
	handle_shrink_and_expand()
	handle_logical_gates()
	handle_movement()

func _on_moved(coords:Vector2i):
	# 頭の上、下の論理ゲートを取得
	above_gate = gate_layer.get_logical_gate(coords + Vector2i(0, -1))
	below_gate = gate_layer.get_logical_gate(coords + Vector2i(0,  1))

func handle_shrink_and_expand():
	# 他のアクション中を実行中は実行しない
	if is_on_action():
		return
	#--------- 膨らむ / 縮む ---------#
	if Input.is_action_just_pressed("expand"):
		expand(EXPAND_DURATION * bit.get_bitwidth(), bit.get_bitwidth())
	if is_expanding and not Input.is_action_pressed("expand"):
		shrink(EXPAND_DURATION * bit.get_bitwidth())

func handle_movement():
	# 他のアクション中を実行中は実行しない
	if is_on_action():
		return
	#--------- 移動 ---------#
	# x、y方向に-1 or 0 or 1移動する移動量を格納
	var movemenet = Vector2i(
		int(Input.get_axis("move_left", "move_right")),
		int(Input.get_axis("move_up", "move_down"))
	)
	# 移動するなら
	if movemenet:
		# 衝突しないなら
		if not will_collide_on_coords(get_tile_position() + movemenet):
			is_moving = true
			# 現在地から移動官僚予定地まで移動し、移動し終わったら
			# is_movingをfalseにするように予約する
			create_tween().tween_property(
				self, "position", position + Vector2(movemenet * TILE_PIXEL),
				movemenet.length() * MOVE_DURATION
			).finished.connect(
				func():
					is_moving = false
					moved.emit(get_tile_position())
			)
		# 衝突したときの演出
		else:
			# 驚いた顔に変化させる
			is_moving = true
			head.texture = surprised_face
			# 半分だけ移動させる
			create_tween().tween_property(
				self, "position", position + Vector2(movemenet * TILE_PIXEL * 0.5),
				movemenet.length() * MOVE_DURATION * 0.5
			# 移動し終わったら戻す
			).finished.connect(func():
				create_tween().tween_property(
					self, "position", position - Vector2(movemenet * TILE_PIXEL * 0.5),
					movemenet.length() * MOVE_DURATION * 0.5
				).finished.connect(
					# 戻り終わり次第移動中フラグを解除し、状態に適した自然な表情に戻す
					func(): is_moving = false; make_face_neutral()
				)
			)

var is_overring_logical_gate = false

var above_gate = LogicalGates.Option.None()
var below_gate = LogicalGates.Option.None()

func handle_logical_gates():
	# アクション中、または膨らんでいない、または上下どちらにもゲートがないならスキップ
	if is_on_action() or not self.is_expanding:
		return
	var above_flag = above_gate.is_some and Input.is_action_just_pressed("move_up")
	var below_flag = below_gate.is_some and Input.is_action_just_pressed("move_down")
	
	if above_flag or below_flag:
		# 頭の上に論理ゲートがある、かつ上に移動しようとしたなら
		var distance:Vector2
		is_overring_logical_gate = true
		if above_flag:
			distance = Vector2(0, -2)
		# 頭の下に論理ゲートがある、かつ下に移動しようとしたなら
		if below_flag:
			distance = Vector2(0, 2)
		create_tween().tween_property(
			self, "position", position + distance * TILE_PIXEL,
			GATE_OVER_DURATION
		).finished.connect(
			func():
				is_overring_logical_gate = false
				moved.emit(get_tile_position())
		)

func change_body_length(length:int):
	body.region_rect.size.x = length * TILE_PIXEL
	body.position.x = (length * TILE_PIXEL) / 2.0 + HALF_TILE
	bit.global_position = visual.global_position + Vector2(TILE_PIXEL, 0)
	tail.position.x = (length + 1) * TILE_PIXEL

func shrink(duration):
	is_width_changing = true
	is_expanding = false
	make_face_neutral()
	create_tween()\
		.tween_property(body, "region_rect:size:x", 0,  duration)
	create_tween()\
		.tween_property(body, "position:x", HALF_TILE,  duration)
	create_tween()\
		.tween_property(tail, "position:x", TILE_PIXEL, duration)\
		.finished\
		.connect(func(): is_width_changing = false)
	bit.shrink(duration)

func expand(duration, length):
	is_width_changing = true
	is_expanding = true
	
	make_face_neutral()
	create_tween()\
		.tween_property(body, "region_rect:size:x", length * TILE_PIXEL,  duration)
	create_tween()\
		.tween_property(body, "position:x", (length * TILE_PIXEL) / 2 + HALF_TILE,  duration)
	create_tween()\
		.tween_property(tail, "position:x", (length + 1) * TILE_PIXEL, duration)\
		.finished\
		.connect(func(): is_width_changing = false)
	bit.expand(duration)

func get_tile_position() -> Vector2i:
	return Vector2i(self.position / TILE_PIXEL)

func is_on_action() -> bool:
	return self.is_moving or self.is_width_changing or self.is_overring_logical_gate

## ある座標に頭があるとき、Wall Layerと衝突するかを判定する
func will_collide_on_coords(coords:Vector2i):
	var own_width = 2
	if is_expanding:
		own_width += bit.get_bitwidth()
	for i in range(own_width):
		var the_coords = coords + Vector2i(i, 0)
		if wall_layer.get_cell_source_id(the_coords) != -1:
			return true
		if gate_layer.get_cell_source_id(the_coords) != -1:
			return true
	return false

func make_face_neutral():
	if is_expanding:
		head.texture = expanded_face
	else:
		head.texture = shrinked_face
