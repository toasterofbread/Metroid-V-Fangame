extends Node2D

export var randomise = false
export var tileset = "asteroid surface"
export var tileset_indices = [0, 1, 0, 1]

var prev_index = -1;
var tileset_resources: Array

const tileset_textures = {
	"asteroid surface": ["res://Assets/Sprites/World/Asteroid/1.png"]
}

const tileset_data = {
	"asteroid surface": [
		[0, Rect2(0, 17, 16, 16), Vector2(0, 0)], [0, Rect2(16, 14, 16, 19), Vector2(0, -1.5)], 
		[0, Rect2(32, 15, 16, 18), Vector2(0, -1)], [0, Rect2(0, 285, 16, 19), Vector2(0, -1.5)],
		[0, Rect2(16, 279, 16, 25), Vector2(0, -4.5)], [0, Rect2(32, 272, 16, 32), Vector2(0, -8)]
	]
}

func _ready():
	
	$Test.queue_free()
	
	if randomise:
		randomize()
	
	var final_tiles = []
	var count = -1
	
	for tile in get_children():
		
		if "World Block (16x16)" in tile.name:
			
			count += 1
			
			tile = tile.get_node("MainTexture")
			
			var index: int
			if randomise:
				index = randi() % tileset_data[tileset].size()
				
				while index == prev_index:
					index = randi() % tileset_data[tileset].size()
					
				prev_index = index
			else:
				index = tileset_indices[count]
			
			var tex = tileset_data[tileset][index]
			
			tile.texture = load(tileset_textures[tileset][tex[0]])
			tile.region_enabled = true
			tile.region_rect = tex[1]
			tile.offset = tex[2]
			
			final_tiles.append(index)
	
	print_debug(final_tiles)
	
	
	
