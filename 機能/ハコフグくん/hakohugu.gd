extends Node2D

@onready var visual:Node2D = $Visual
@onready var head:Sprite2D = $Visual/Head
@onready var body:Sprite2D = $Visual/Body
@onready var tail:Sprite2D = $Visual/Tail

var bits_sprite:Array[Sprite2D]

@export_subgroup("ハコフグ")
@export var is_expanding:bool:
	set(value):
		toggle_expanded(value)
@export var bit_capacity:int = 8:
	set(value):
		update_memory_capacity(value)
		bit_capacity = value
@export var fish_value:int:
	set(value):
		update_value(value)
		fish_value = value

@export_subgroup("依存関係")
@export var world:World

## 各処理で参照される定数群
const PIXEL_TILE = 16
const HALF_TILE = 8
const LENGTH_CHANGE_TIME_PER_BIT = 0.05
const SWAY_WIDTH = 2
const SWAY_FREQ = 2
const MOVE_SPEED = 0.25

## 事前にテクスチャを読み込んでおくことで毎回読み込む処理の負荷を軽減する
@onready var EXPANDED_TEXTURE   = preload("res://機能/ハコフグくん/テクスチャ/ハコフグくん_頭_膨らむ.png")
@onready var CONTRACTED_TEXTURE = preload("res://機能/ハコフグくん/テクスチャ/ハコフグくん_頭.png")

@onready var ZERO_TEXTURE = preload("res://機能/ハコフグくん/テクスチャ/ゼロ.png")
@onready var ONE_TEXTURE  = preload("res://機能/ハコフグくん/テクスチャ/イチ.png")



## 中に書いた処理がシーンを再生した時に実行される
func _ready() -> void:
	bit_capacity = 8
	fish_value = 0b10101010
	force_update_width(0)

## 中に書いた処理が毎ティック実行される
var time_counter = 0
var is_moving:bool

func _physics_process(delta: float) -> void:
	# ハコフグを揺らすために経過時間を数える
	time_counter += delta
	
	# どっちの方向に移動するかを格納する
	# Input.get_axis(..., ...)
	# 最初の引数のアクションをマイナス、二つ目のアクションをプラスとして
	# -1 ~ 1までの値でfloatの出力を返す
	# ハコフグくんにはマス単位で動いてほしいのでintにキャストする
	var movement = Vector2i(
		int(Input.get_axis("move_left", "move_right")),
		int(Input.get_axis("move_up", "move_down"))
	)
	
	# 膨らむアクションが押されたら膨らむ、離されたら縮む
	if Input.is_action_just_pressed("expand"):
		toggle_expanded(true)
	if Input.is_action_just_released("expand"):
		toggle_expanded(false)
	
	# time_counterをsinにかけてゆらゆら揺らす
	visual.position.y = sin(time_counter * SWAY_FREQ) * SWAY_WIDTH
	
	# 移動距離|a→|が0でなければ移動する
	if movement and not is_moving:
		is_moving = true
		await create_tween()\
			.tween_property(
				self,
				"position",
				position + Vector2(movement * PIXEL_TILE),
				MOVE_SPEED
			)\
			.finished
		is_moving = false


## ハコフグに表示されている数字を引数の数字に更新する
func update_value(value:int):
	var length = len(bits_sprite)-1
	for i in length+1:
		if (value >> i) & 1:
			bits_sprite[length-i].texture = ONE_TEXTURE
		else:
			bits_sprite[length-i].texture = ZERO_TEXTURE

## ハコフグのビットキャパシティを更新する
func update_memory_capacity(width):
	if width >= 0:
		body.region_rect.size.x = width * PIXEL_TILE
		body.position.x = (width + 1) * HALF_TILE
		tail.position.x = (width + 1) * PIXEL_TILE
		for child in bits_sprite:
			child.queue_free()
		bits_sprite = []
		for i in width:
			var bit = Sprite2D.new()
			bit.texture = ZERO_TEXTURE
			bit.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			bit.z_index = 1
			bit.visible = false
			bit.position.x = PIXEL_TILE * (i + 1) - 4
			bits_sprite.push_back(bit)
			visual.add_child(bit)

## 強制的にハコフグをあるビットの長さにする、演出なし
func force_update_width(width:int):
	body.region_rect.size.x = get_bodylength_when(width)
	body.position.x = get_bodypos_when(width)
	tail.position.x = get_tailpos_when(width)

## 演出込みで引数がtrueの時膨らみ、falseの時縮む
func toggle_expanded(given:bool):
	if given:
		head.texture = EXPANDED_TEXTURE
		expand_to(bit_capacity, bit_capacity * LENGTH_CHANGE_TIME_PER_BIT)
	else:
		head.texture = CONTRACTED_TEXTURE
		expand_to(0, bit_capacity * LENGTH_CHANGE_TIME_PER_BIT)

## あるビットの長さの時の体のx方向の長さを取得する純粋関数
func get_bodylength_when(bit_width:int) -> int:
	return bit_width * PIXEL_TILE

## あるビットの長さの時の体のx座標を取得する純粋関数
func get_bodypos_when(bit_width:int) -> int:
	return max(bit_width * HALF_TILE, HALF_TILE)

## あるビットの長さの時の尾のx座標を取得する純粋関数
func get_tailpos_when(bit_width:int) -> int:
	return max(((bit_width + 1) * PIXEL_TILE) - HALF_TILE, PIXEL_TILE)

## 演出込みでハコフグを特定の長さまで伸ばす/縮める
func expand_to(bit_width:int, duration:float):
	# 現時点で何ビット表示されているか数える
	var count:int = 0
	for i in len(bits_sprite)-1:
		if bits_sprite[i].visible:
			count += 1
	# 何ビット分に処理をかけるか確定させる
	var gap = count - bit_width
	# 一ビットの表示非表示に使う時間を計算
	var one_bit_duration = duration / abs(gap)
	
	# 頭、胴体、尾を移動する
	create_tween().tween_property(
		body,
		"region_rect:size:x",
		get_bodylength_when(bit_width),
		duration
	)
	create_tween().tween_property(
		body,
		"position:x",
		get_bodypos_when(bit_width),
		duration
	)
	create_tween().tween_property(
		tail,
		"position:x",
		get_tailpos_when(bit_width),
		duration
	)
	
	# 現時点で目標の長さより短かったら
	if gap >= 0:
		for i in abs(gap) + 1:
			# 今の配列のインデクス
			var now = count - i
			get_tree()\
				.create_timer(i * one_bit_duration)\
				.timeout\
				.connect(func(): bits_sprite[now].visible = false)
	# 現時点で目標の長さより長かったら
	else:
		for i in abs(gap):
			get_tree()\
				.create_timer(i * one_bit_duration)\
				.timeout\
				.connect(func(): bits_sprite[count+i].visible = true)
