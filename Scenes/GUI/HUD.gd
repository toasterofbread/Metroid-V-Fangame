extends Control

const etank_texture_full = preload("res://Assets/Sprites/Samus/E-Tank icon full.png")
const etank_texture_empty = preload("res://Assets/Sprites/Samus/E-Tank icon empty.png")
const weapon_icons_frames = preload("res://Scenes/GUI/weapon icons.tres")
const weapon_numeral_frames = preload("res://Assets/Sprites/Other/Text/Weapon numerals/Weapon numerals.tres")
const bg_texture = preload("res://Assets/Sprites/Other/Square.png")


var armed = false
var weapon_icons = []
var energy_tanks = []
var energy_bg_size_add = [0, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	addEtanks()
	addWeapons()
	updateEnergy()

	for weapon in GLOBAL.selectable_weapons + GLOBAL.selectable_weapons_morph:
		updateWeapon(weapon[0])
		
	weapon_icons[0].get_node("icon").frame = 1
	



# Updates the specified weapon quantity on the HUD
func setAmount(mode:String):
	
	match mode:
		"etanks": addEtanks()
		"weapons": addWeapons()



func addEtanks():
	
	for tank in energy_tanks:
		tank.queue_free()
	energy_tanks = []

	$CanvasLayer/Energy/Background.position.x -= energy_bg_size_add[0]
	$CanvasLayer/Energy/Background.scale.x -= energy_bg_size_add[1]
	energy_bg_size_add = [0, 0]
	
	if GLOBAL.samusData["upgrades"]["etank"] > 0:
	
		$CanvasLayer/Energy/Background.position.x += 2
		$CanvasLayer/Energy/Background.scale.x += 0.251
		
		energy_bg_size_add[0] += 2
		energy_bg_size_add[1] += 0.251
		
		for count in range(GLOBAL.samusData["upgrades"]["etank"]):
			
			var tank = Sprite.new()
			
			tank.texture = etank_texture_full
			tank.centered = false
			
			if count % 2 == 0:
				tank.position.x = 6 * count / 2
				
				$CanvasLayer/Energy/Background.position.x += 3
				$CanvasLayer/Energy/Background.scale.x += 0.375
	
				energy_bg_size_add[0] += 3
				energy_bg_size_add[1] += 0.375
	
			elif count % 2 == 1:
				tank.position.x = 6 * (count - 1) / 2
				tank.position.y = 6
	
			$CanvasLayer/Energy/ETanks.add_child(tank)
			energy_tanks.append(tank)
			
			
func addWeapons():

	for icon in weapon_icons:
		icon.queue_free()
	weapon_icons = []

	var text_amount = 0
	var count = -1
	for weapon in GLOBAL.selectable_weapons + GLOBAL.selectable_weapons_morph:
		weapon = weapon[0]
		if GLOBAL.samusData["upgrades"][weapon] == 0:
			continue
		
		count += 1
		
		var node = Node2D.new()
		node.position = Vector2(45, 10)
		node.position.x += 4 + (45 * count) + (7 * text_amount)
		node.position.x += energy_bg_size_add[0] * 2
		
		
		var icon = AnimatedSprite.new()
		icon.frames = weapon_icons_frames
		icon.animation = weapon
		icon.position = Vector2(4, 2)
		icon.centered = false
		icon.name = "icon"
		
		var bg = Sprite.new()
		bg.scale.y = 1
		bg.scale.x = 2.3
		bg.texture = bg_texture
		bg.modulate = $CanvasLayer/Energy/Background.modulate
		bg.centered = false
		bg.z_index = -1
		
		for i in range(len(str(GLOBAL.samusData["upgrades"][weapon] * GLOBAL.amount_gained_per_tank[weapon]))):
			i += 1
			
			if i > 1:
				bg.scale.x += 0.45
				text_amount += 1
			
			var text = AnimatedSprite.new()
			text.frames = weapon_numeral_frames
			text.position.y = 8
			text.position.x = 20 + (7 * i)
		
			text.name = "Digit" + str(i)
			
			node.add_child(text)
		
		node.add_child(icon)
		node.add_child(bg)
		
		node.name = weapon
		weapon_icons.append(node)
		$CanvasLayer.add_child(node)
		
		if energy_bg_size_add != [0, 0]:
			pass
		
func updateEnergy():
	
	var energy = GLOBAL.samusData["amounts"]["energy"]
	
	if len(str(energy % 100)) == 1:
		$CanvasLayer/Energy/Digit1.frame = 0
		$CanvasLayer/Energy/Digit2.frame = int(str(energy % 100)[0])
	else:
		$CanvasLayer/Energy/Digit1.frame = int(str(energy % 100)[0])
		$CanvasLayer/Energy/Digit2.frame = int(str(energy % 100)[1])
	
	var count = energy / 100
	
	for tank in energy_tanks:
		if count > 0:
			tank.texture = etank_texture_full
			count -= 1
		else:
			tank.texture = etank_texture_empty
			
func updateWeapon(weapon:String):
	
	var amount = GLOBAL.samusData["amounts"][weapon]
	var node = get_node("CanvasLayer/" + weapon)
	
	for digit in range(len(str(amount))):
		digit += 1
		node.get_node("Digit" + str(digit)).frame = int(str(amount)[digit - 1])
		
	
func selectWeapon(index, morph):
	
	var weapons: Array
	match morph:
		true: 
			weapons = GLOBAL.selectable_weapons_morph
		false: 
			weapons = GLOBAL.selectable_weapons

	for weapon in weapon_icons:
		if weapon.name == weapons[index][0]:
			if armed:
				weapon.get_node("icon").frame = 2
			else:
				weapon.get_node("icon").frame = 1
		else:
			weapon.get_node("icon").frame = 0


func armWeapon(opt:bool):
	
	if opt:
		armed = true
		for weapon in weapon_icons:
			if weapon.get_node("icon").frame == 1:
				weapon.get_node("icon").frame = 2
	else:
		armed = false
		for weapon in weapon_icons:
			if weapon.get_node("icon").frame == 2:
				weapon.get_node("icon").frame = 1
