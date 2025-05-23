@tool
extends Node2D

@export var body:Sprite2D
@export var tail:Sprite2D

@export var bits_sprite:Array[Sprite2D]

@export var bits:int = 8:
	set(value):
		if value >= 0:
			body.region_rect.size.x = value << 4
			body.position.x = (value + 1) << 3
			tail.position.x = (value + 1) << 4
			for child in bits_sprite:
				child.queue_free()
			bits_sprite = []
			for i in value:
				var bit = Sprite2D.new()
				bit.texture = preload("res://機能/ハコフグくん/テクスチャ/ゼロ.png")
				bit.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				bit.position.x = 16 * (i + 1)
				bits_sprite.push_back(bit)
				add_child(bit)
			bits = value
@export var fish_value:int:
	set(value):
		var length = len(bits_sprite)-1
		for i in length+1:
			if (value >> i) & 1:
				bits_sprite[length-i].texture = preload("res://機能/ハコフグくん/テクスチャ/イチ.png")
			else:
				bits_sprite[length-i].texture = preload("res://機能/ハコフグくん/テクスチャ/ゼロ.png")
		fish_value = value
