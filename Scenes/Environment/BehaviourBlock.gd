extends Node2D

export var block_type: String
var psuedo_tile = ""

const type_rules = {
	"beam": ["beam", "missile", "bomb", "power bomb", "super missile", "screw attack", "speed booster"],
	"bomb": ["bomb", "power bomb"],
	"missile": ["missile", "super missile"],
	"super missile": ["super missile"],
	"screw attack": ["screw attack"],
	"power bomb": ["power bomb"]
}

func _ready():
	
	$AnimatedSprite.animation = block_type
	show_behind_parent = true


func handleShot(shot_type):
	
	if shot_type[0] in type_rules[block_type]:
	
		if not psuedo_tile is String:
			psuedo_tile.queue_free()
	
		$AnimatedSprite.animation = "destruction"
		yield($AnimatedSprite, "animation_finished")
		$AnimatedSprite.playing = false

		$AnimatedSprite.visible = false
		$Area2D/CollisionShape2D2.disabled = true
		$StaticBody2D/CollisionShape2D.disabled = true
		
		$AnimatedSprite.animation = "beam"
		
	elif "bomb" in shot_type[0] and not psuedo_tile is String:
		psuedo_tile.queue_free()



func _on_Area2D_body_entered(body):

	if body is TileMap and psuedo_tile == "":
		
		var tile = body.get_cellv(position / 16)
		
		var texture_offset = body.tile_set.tile_get_texture_offset(tile)
		var texture = body.tile_set.tile_get_texture(tile)
		var texture_region = body.tile_set.tile_get_region(tile)
		
		body.set_cellv(position / 16, -1)
		
		psuedo_tile = Sprite.new()
		
		psuedo_tile.centered = false
		psuedo_tile.offset = texture_offset
		psuedo_tile.texture = texture
		psuedo_tile.region_enabled = true
		psuedo_tile.region_rect = texture_region
		
		body.add_child(psuedo_tile)
		
		psuedo_tile.position = position
