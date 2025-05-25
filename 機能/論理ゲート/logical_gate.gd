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

var one  = preload("res://機能/論理ゲート/イチ.png")
var zero = preload("res://機能/論理ゲート/ゼロ.png")

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
		head_sprite.position.x = 8
		add_child(head_sprite)
		
		# Make a body
		body_sprite = Sprite2D.new()
		body_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		body_sprite.region_enabled = true
		body_sprite.region_rect.size = Vector2(16 * length, 16)
		body_sprite.position.x = (length + 2) << 3
		body_sprite.texture = body
		add_child(body_sprite)
		
		for i in length:
			var bit_sprite = Sprite2D.new()
			bit_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			if (value >> i) & 1:
				bit_sprite.texture = one
			else:
				bit_sprite.texture = zero
			bit_sprite.position.x = ((length - i) << 4) + 4
			bit_sprite.z_index = 1
			bits_sprites.push_front(bit_sprite)
			add_child(bit_sprite)
		
		tail_sprite = Sprite2D.new()
		tail_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tail_sprite.texture = tail
		tail_sprite.position.x = (length + 1) << 4
		add_child(tail_sprite)

func _ready() -> void:
	update()
