@tool
extends Node2D
class_name LogicalGate

@export_subgroup("テクスチャ")
@export var head:CompressedTexture2D
@export var body:CompressedTexture2D
@export var tail:CompressedTexture2D

@export_subgroup("論理ゲート")
@export var value:int = 16:
	set(_value):
		value = _value
		update()
@export var length:int = 8:
	set(value):
		length = value
		update()

@onready var ONE  = preload("res://機能/論理ゲート/イチ.png")
@onready var ZERO = preload("res://機能/論理ゲート/ゼロ.png")

const PIXEL_TILE = 16
const HALF_TILE  = 8

var head_sprite:Sprite2D
var body_sprite:Sprite2D
var bits_sprites:Array[Sprite2D]
var tail_sprite:Sprite2D

func update():
	if length >= 0:
		# Free everything
		if head_sprite != null:
			head_sprite.queue_free()
			head_sprite = null
		if body_sprite != null:
			body_sprite.queue_free()
			body_sprite = null
		for bit in bits_sprites:
			bit.queue_free()
		bits_sprites = []
		if tail_sprite != null:
			tail_sprite.queue_free()
			tail_sprite = null
		
		# Make a head
		head_sprite = Sprite2D.new()
		head_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		head_sprite.texture = head
		head_sprite.position = Vector2(HALF_TILE, HALF_TILE)
		add_child(head_sprite)
		
		# Make a body
		body_sprite = Sprite2D.new()
		body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		body_sprite.region_enabled = true
		body_sprite.region_rect.size = Vector2(PIXEL_TILE * length, PIXEL_TILE)
		body_sprite.position = Vector2((length + 2) * HALF_TILE, HALF_TILE)
		body_sprite.texture = body
		add_child(body_sprite)
		
		for i in length:
			var bit_sprite = Sprite2D.new()
			bit_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			if (value >> i) & 1:
				bit_sprite.texture = ONE
			else:
				bit_sprite.texture = ZERO
			bit_sprite.position = Vector2(((length - i) * PIXEL_TILE) + 8, HALF_TILE)
			bit_sprite.z_index = 2
			bits_sprites.push_front(bit_sprite)
			add_child(bit_sprite)
		
		tail_sprite = Sprite2D.new()
		tail_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tail_sprite.texture = tail
		tail_sprite.position = Vector2((length + 1) * PIXEL_TILE, HALF_TILE)
		add_child(tail_sprite)

func _ready() -> void:
	update()
