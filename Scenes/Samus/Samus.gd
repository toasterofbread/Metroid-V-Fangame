extends KinematicBody2D

# Export variables
export var camera_limits = {
	"Left": -10000000,
	"Top": -10000000,
	"Right": 10000000,
	"Bottom": 10000000
}
export var starting_animation = "neutral"
export var start_without_physics = false

# Physics constants
const run_speed = 150

const jump_vert_speed = 175
const max_jump_height = 60
const spin_horiz_speed = 90
const jump_horiz_speed = 100

const morph_ball_speed = 150

const passive_gravity = 15
const max_fall_speed = 215

const slope_threshold = deg2rad(20)
var slope_snap = Vector2.DOWN * 10.0

# Node variables
onready var HUD = get_parent().get_node("HUD")
var audio_channels = []

# Assets
const shot_scene = preload("res://Scenes/Samus/shotScene.tscn")
const sounds = {
	"land": preload("res://Assets/Sounds/Samus/Land.ogg"),
	"spin": preload("res://Assets/Sounds/Samus/Spin.ogg")
}

# Other
const continuous_animations = {
	"run": ["run aim up", "run aim down", "run fire"],
	"run aim up": ["run", "run aim down", "run fire"],
	"run aim down": ["run", "run aim up", "run fire"],
	"run fire": ["run", "run aim up", "run aim down"]
}
var facing = "right"
var aiming = "none"
var arming_weapon = false
var falling = false
var spinning = false
var jump_origin = ""
var run_physics = false
var mode = ""
var velocity = Vector2(0, 0)
var animation_cache = []
var awaiting_animation = false
var spinChannel = ""
var hitstun = false
var decor_anim = null
var run_firing = false
var selected_weapon = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	print([$HurtBox.shape.extents, $HurtBox.position])
	
	# Apply the exported camera limit variables to the camera
	$Camera2D.limit_left = camera_limits["Left"]
	$Camera2D.limit_top = camera_limits["Top"]
	$Camera2D.limit_right = camera_limits["Right"]
	$Camera2D.limit_bottom = camera_limits["Bottom"]
	
	# Cache Samus's audio channels to an array
	for child in $AudioChannels.get_children():
		audio_channels.append(child)
	
	# Wait for the parent node to emit the ready signal
	print_debug("(SAMUS) Awaiting ready signal from parent")
	yield(get_parent(), "samus_ready")
	print_debug("(SAMUS) Recieved ready signal from parent")
	
	# Start Samus's physics
	if start_without_physics:
		playAnimation(starting_animation)
	else:
		run_physics = true
		
func _physics_process(delta):

	if not run_physics:
		return
		
	if hitstun:
		return
		
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
		
	var start_facing = facing
	var start_aiming = aiming
	
	if mode in ["run", "idle", "crouch", "jump"]:
		
		if Input.is_action_pressed("joy_l_up"):
			run_firing = true
			aiming = "up"
		elif Input.is_action_pressed("joy_l_down"):
			run_firing = true
			aiming = "down"
		
		elif Input.is_action_pressed("aim"):
			run_firing = true
			if aiming != "none":
				if Input.is_action_just_pressed("down"):
					aiming = "down"
				elif Input.is_action_just_pressed("up"):
					aiming = "up"
			else:
				if Input.is_action_pressed("down"):
					aiming = "down"
				else:
					aiming = "up"
		
		elif mode == "run":
			if Input.is_action_pressed("up"):
				aiming = "up"
				run_firing = true
			elif Input.is_action_pressed("down"):
				aiming = "down"
				run_firing = true
			else:
				aiming = "none"
		else:
			aiming = "none"
	else:
		aiming = "none"

	
	

	
	if aiming != start_aiming:
		decor_anim = null
		
	if Input.is_action_just_pressed("select_weapon"):
		if mode == "morph ball":
			cycleWeapon("next", true)
		else:
			cycleWeapon("next", false)
	elif Input.is_action_just_pressed("cancel_weapon_selection"):
		if mode == "morph ball":
			cycleWeapon("cancel", true)
		else:
			cycleWeapon("cancel", false)
	
	if Input.is_action_pressed("arm_weapon"):
		if not arming_weapon:
			arming_weapon = true
			cycleWeapon("arm", true)
			setSpriteVisibility()
			
	elif arming_weapon:
		arming_weapon = false
		cycleWeapon("arm", false)
		setSpriteVisibility()
	
	
	if Input.is_action_just_pressed("move_left") and facing != "left":
		facing = "left"
		decor_anim = null
		
	elif Input.is_action_just_pressed("move_right") and facing != "right":
		facing = "right"
		decor_anim = null
		
	elif Input.is_action_just_pressed("joy_l_left") and facing != "left" and velocity.x == 0 and not awaiting_animation and not "turn" in $LeftSpriteUnarmed.animation:
		facing = "left"
		turnAnimation($LeftSpriteUnarmed.animation + " turn")
		decor_anim = null
	elif Input.is_action_just_pressed("joy_l_right") and facing != "right" and velocity.x == 0 and not awaiting_animation and not "turn" in $LeftSpriteUnarmed.animation:
		facing = "right"
		turnAnimation($LeftSpriteUnarmed.animation + " turn")
		decor_anim = null
		

	if not is_on_floor() and not mode in ["morph ball", "jump"]:
		mode = "jump"
		decor_anim = null
		falling = true

	
	while true:
		if mode in ["run", "idle"] and is_on_floor():
			
			if Input.is_action_just_pressed("down") and mode == "idle" and start_aiming != "up":
				mode = "crouch"
				decor_anim = null
				break
			elif Input.is_action_just_pressed("jump"):
				mode = "jump"
				decor_anim = null
				falling = false
				jump_origin = position.y
				velocity.y = -jump_vert_speed
				
				if velocity.x != 0:
					spinning = true	
				else:
					turnAnimation("rising start")
				break
			if Input.is_action_pressed("move_left"):
				
				if start_facing == "left" and not awaiting_animation and $TurnAnimationCooldown.time_left == 0:
					if mode != "run":
						decor_anim = null
						mode = "run"
						
					velocity.x = -run_speed
				elif start_facing == "right":
					decor_anim = null
					match aiming:
						"up": turnAnimation("idle aim side up turn")
						"down": turnAnimation("idle aim side down turn")
						"none":
							if mode == "idle" and Input.is_action_pressed("up"):
								turnAnimation("idle aim up turn")
							else:
								turnAnimation("idle turn")
			elif Input.is_action_pressed("move_right"):
				if start_facing == "right" and not awaiting_animation and $TurnAnimationCooldown.time_left == 0:
					if mode != "run":
						decor_anim = null
						mode = "run"
						
					velocity.x = run_speed
				elif start_facing == "left":
					decor_anim = null
					match aiming:
						"up": turnAnimation("idle aim side up turn")
						"down": turnAnimation("idle aim side down turn")
						"none":
							if mode == "idle" and Input.is_action_pressed("up"):
								turnAnimation("idle aim up turn")
							else:
								turnAnimation("idle turn")
			else:
				if mode != "idle":
					decor_anim = null
					mode = "idle"
				velocity.x = 0
				
			if Input.is_action_pressed("arm_weapon") and not run_firing:
				run_firing = true
				setSpriteVisibility()
				
		elif mode == "jump":
		
			if is_on_floor() and falling:
	#			playSound("land")
				mode = "idle"
				
				falling = false
				spinning = false
				slope_snap = Vector2.DOWN * 10.0
				break
			elif is_on_floor():
				slope_snap = Vector2.ZERO
				
			if not falling:
				
				if Input.is_action_just_released("jump") or is_on_ceiling() or position.y <= jump_origin - max_jump_height:
					falling = true
					decor_anim = null
				else:
					velocity.y = -jump_vert_speed
			
			if not spinning:
				
				if Input.is_action_just_pressed("jump"):
					spinning = true
					falling = true
				
				if Input.is_action_pressed("move_left"):
					velocity.x = -jump_horiz_speed
				elif Input.is_action_pressed("move_right"):
					velocity.x = jump_horiz_speed
				else:
					velocity.x = 0
			else:
				if Input.is_action_pressed("move_left"):
					velocity.x = -spin_horiz_speed
				elif Input.is_action_pressed("move_right"):
					velocity.x = spin_horiz_speed
				else:
					if velocity.x > spin_horiz_speed or velocity.x < -spin_horiz_speed:
						lerp(velocity.x, spin_horiz_speed, 0.5)
					else:
						match facing:
							"right": velocity.x = spin_horiz_speed
							"left": velocity.x = -spin_horiz_speed
						
						
				if Input.is_action_pressed("fire"):
					shot()
					spinning = false
					falling = true
				
		elif mode == "crouch":
			
			velocity.x = 0
			if Input.is_action_pressed("move_left"):
				if start_facing == "left" and not awaiting_animation and $TurnAnimationCooldown.time_left == 0:
					mode = "run"
					decor_anim = null
					break
				elif start_facing == "right":
					decor_anim = null
					match aiming:
						"up": turnAnimation("crouch aim up turn")
						"down": turnAnimation("crouch aim down turn")
						"none": turnAnimation("crouch turn")
					
			elif Input.is_action_pressed("move_right"):
				if start_facing == "right" and not awaiting_animation and $TurnAnimationCooldown.time_left == 0:
					mode = "run"
					decor_anim = null
					
					if Input.is_action_pressed("arm_weapon"):
						run_firing = true
						
					break
				elif start_facing == "left":
					decor_anim = null
					match aiming:
						"up": turnAnimation("crouch aim up turn")
						"down": turnAnimation("crouch aim down turn")
						"none": turnAnimation("crouch turn")
				
			elif Input.is_action_just_pressed("jump") and not $CeilingDetector.is_colliding():
				
				decor_anim = null
				mode = "jump"
				falling = false
				jump_origin = position.y
				
				if velocity.x != 0:
					spinning = true
					velocity.x -= velocity.x * 0.2
				else:
					turnAnimation("rising start")
	
				
			elif Input.is_action_just_pressed("up") and start_aiming != "down":
				if not $CeilingDetector.is_colliding():
					decor_anim = null
					mode = "idle"
			elif Input.is_action_just_pressed("down") and GLOBAL.samusData["upgrades"]["morph ball"] > 0 and start_aiming != "up":
				mode = "morph ball"
				cycleWeapon("cancel", true)
				decor_anim = null
				turnAnimation("to morph")
				
			
				
		elif mode == "morph ball":
			
			if (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("jump")) and not $CeilingDetector.is_colliding():
				mode = "crouch"
				cycleWeapon("cancel", false)
				turnAnimation("from morph")
				position.y += 1
				break
			
			if Input.is_action_pressed("move_left"):
				velocity.x = -morph_ball_speed
				$LeftSpriteArmed.playing = true
				$RightSpriteArmed.playing = true
				$LeftSpriteUnarmed.playing = true
				$RightSpriteUnarmed.playing = true
			elif Input.is_action_pressed("move_right"):
				velocity.x = morph_ball_speed
				$LeftSpriteArmed.playing = true
				$RightSpriteArmed.playing = true
				$LeftSpriteUnarmed.playing = true
				$RightSpriteUnarmed.playing = true
			else:
				velocity.x = 0
				if $LeftSpriteUnarmed.animation == "morph ball":
					$LeftSpriteArmed.playing = false
					$RightSpriteArmed.playing = false
					$LeftSpriteUnarmed.playing = false
					$RightSpriteUnarmed.playing = false
				
		break
	
	if not awaiting_animation and Input.is_action_just_pressed("fire") and mode in ["run", "idle", "crouch", "jump"]:
		shot()
	
	if mode != "run":
		run_firing = false
	
	# Play animation based on mode and aiming variables
	if not awaiting_animation and decor_anim == null:
		match mode:
			"run": match aiming:
				"up": playAnimation("run aim up")
				"down": playAnimation("run aim down")
				"none": 
					if run_firing:
						playAnimation("run fire")
					else:
						playAnimation("run")
			"idle": match aiming:
				"up": playAnimation("idle aim side up")
				"down": playAnimation("idle aim side down")
				"none": 
					if Input.is_action_pressed("up"):
						playAnimation("idle aim up")
					else:
						playAnimation("idle")
			"jump": 
				if spinning:
					playAnimation("spin")
				elif falling and velocity.y > 0:
					playAnimation("falling")
				else:
					playAnimation("rising")
			"crouch": match aiming:
				"up": playAnimation("crouch aim up")
				"down": playAnimation("crouch aim down")
				"none": playAnimation("crouch")
			"morph ball": playAnimation("morph ball")

	# apply gravity to the velocity
	if (mode != "jump" or falling) and velocity.y < max_fall_speed:
		velocity.y += passive_gravity
	
	# move based on final velocity
	velocity = move_and_slide_with_snap(velocity, slope_snap, Vector2.UP, true, 4, slope_threshold)

#	if spinning and spinChannel is String:
#		spinChannel = playSound("spin")
#
#	elif not spinning and not spinChannel is String:
#		spinChannel.stop()
#		spinChannel = ""


# Handles firing weapons
func shot():

	# Return if weapon ammo is empty
	if arming_weapon:
		if mode == "morph ball":
			if GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons_morph[selected_weapon][0]] <= 0:
				return
		else:
			if GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons[selected_weapon][0]] <= 0:
				return

	# Determine direction of shot
	var dir = ""
	match aiming:
		"up": match facing:
			"right": dir = "up right"
			"left": dir = "up left"
		"down": match facing:
			"right": dir = "down right"
			"left": dir = "down left"
		"none": 
			if $LeftSpriteUnarmed.animation == "idle aim up":
				dir = "up"
			else:
				match facing:
					"right": dir = "right"
					"left": dir = "left"
	
	# Play firing animation
	match $LeftSpriteUnarmed.animation:
		"run": run_firing = true
		"idle aim up": decorAnim("idle aim up fire")
		"idle aim side up": decorAnim("idle aim side up fire")
		"idle aim side down": decorAnim("idle aim side down fire")
		"idle": decorAnim("idle fire")
		"crouch": decorAnim("crouch fire")
		"crouch aim up": decorAnim("crouch aim up fire")
		"crouch aim down": decorAnim("crouch aim down fire")
	
	# Create an instance of the shot scene
	var shot = shot_scene.instance()
	
	# Set the shot's type and direction
	match arming_weapon:
		false: shot.type = ["beam"]
		true: 
			if mode == "morph ball":
				shot.type = [GLOBAL.selectable_weapons_morph[selected_weapon][0]]
			else:
				shot.type = [GLOBAL.selectable_weapons[selected_weapon][0]]
	shot.direction = dir
	
	# Add the shot to the game
	get_parent().add_child(shot)

	# Set the shot's position
	shot.global_position = $ShotLocation.global_position
	
	# Reduce ammo amount and update HUD
	if arming_weapon:
		if mode == "morph ball":
			GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons_morph[selected_weapon][0]] -= 1
			HUD.updateWeapon(GLOBAL.selectable_weapons_morph[selected_weapon][0])
			if GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons_morph[selected_weapon][0]] <= 0:
				cycleWeapon("cancel", true)
		else:
			GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons[selected_weapon][0]] -= 1
			HUD.updateWeapon(GLOBAL.selectable_weapons[selected_weapon][0])
			if GLOBAL.samusData["amounts"][GLOBAL.selectable_weapons[selected_weapon][0]] <= 0:
				cycleWeapon("cancel", false)
	

# Handles playing Samus's sounds
func playSound(sound:String):
	
	# Iterate through all of Samus's audio channels unti one that is not currently playing anything is found
	for channel in audio_channels:
		if not channel.playing:
			
			# Play the sound with the channel and return it so it can be used with yield
			channel.stream = sounds[sound]
			channel.play()
			
			return channel
	
	# If there was no available channel, notify in the debug output
	print_debug("Not enough audio channels on Samus (Sound: ", sound, ")")
	
# Handles Samus's animations
func playAnimation(anim:String):
	
	# If the animation is the same as the current animation, don't run the rest of the funciton
	if [anim, facing] == animation_cache:
		return
	else:
		animation_cache = [anim, facing]

	if anim != "morph ball":
		$LeftSpriteArmed.playing = true
		$RightSpriteArmed.playing = true
		$LeftSpriteUnarmed.playing = true
		$RightSpriteUnarmed.playing = true

	var anim_frame = 0
	if anim in continuous_animations.keys():
		if $LeftSpriteUnarmed.animation in continuous_animations[anim]:
			anim_frame = $LeftSpriteUnarmed.frame
	
	setSpriteVisibility()

	# Set Samus's hurtbox based on her new animation
	var hurtbox: Array

	match anim:
		
		"idle", "idle fire", "idle turn", "run", "run fire", "idle aim side down", "idle aim side up", "run aim up", "run aim down", "idle aim side up turn", "idle aim side down turn", "idle aim up turn", "idle aim side up fire", "idle aim side down fire": match facing:
			"left": hurtbox = [Vector2(5.98305, 16.642), Vector2(1.59481, 0.257665)]
			"right": hurtbox = [Vector2(5.98305, 16.642), Vector2(-1.99498, 0.257665)]
		"idle aim up", "idle aim up fire": match facing:
			"left": hurtbox = [Vector2(6, 17), Vector2(1, 0)]
			"right": hurtbox = [Vector2(6, 17), Vector2(-1, 0)]
		"crouch", "from morph", "crouch fire", "crouch turn", "crouch aim up", "crouch aim up fire", "crouch aim down", "crouch aim down fire", "crouch aim up turn", "crouch aim down turn": match facing:
			"left": hurtbox = [Vector2(5.98305, 12.5634), Vector2(2.82546, 4.49368)]
			"right": hurtbox = [Vector2(5.98305, 12.5634), Vector2(-2.9383, 4.49368)]
		"spin", "falling", "rising", "rising start": hurtbox = [Vector2(7.31087, 7.62155), Vector2(-0.066463, 4.1347)]
#		"to morph", "from morph": hurtbox = [Vector2(7.31087, 7.62155), Vector2(0, 0)]
		"morph ball", "to morph": hurtbox = [Vector2(6, 8), Vector2(0, 10)]
		
	$HurtBox.shape.extents = hurtbox[0]
	$HurtBox.position = hurtbox[1]
	
	# Set sprite position
	var pos = Vector2(0, 0)
	
	match anim:
		"crouch": pos = Vector2(0, 5)
		"crouch fire": match facing:
			"right": pos = Vector2(-2, 5)
			"left": pos = Vector2(1, 4)
		"crouch aim up", "crouch aim up turn": match facing:
			"right": pos = Vector2(0, 3)
			"left": pos = Vector2(-1, 3)
		"crouch aim up fire": match facing:
			"right": pos = Vector2(-1, 3)
			"left": pos = Vector2(0, 3)
		"crouch aim down", "crouch aim down turn": match facing:
			"right": pos = Vector2(0, 5)
			"left": pos = Vector2(-1, 5)
		"crouch aim down fire": match facing:
			"right": pos = Vector2(0, 5)
			"left": pos = Vector2(0, 5)
		"crouch turn": match facing:
			"right": pos = Vector2(-4, 4)
			"left": pos = Vector2(2, 4)
		"spin": pos = Vector2(0, 4.011)
		"idle fire": match facing:
			"left": pos = Vector2(1, 0)
			"right": pos = Vector2(-1, 0)
		"idle aim up", "idle aim up turn", "idle aim up fire": match facing:
			"right": pos = Vector2(-4, -5)
			"left": pos = Vector2(4, -5)
		"idle aim side up": match facing:
			"right": pos = Vector2(0, -1)
			"left": pos = Vector2(-1, -1)
		"idle aim side up fire": pos = Vector2(0, -1)
		"idle aim side up turn": match facing:
			"right": pos = Vector2(-5, -1)
			"left": pos = Vector2(4, -1)
		"idle aim side down turn": match facing:
			"left": pos = Vector2(3, 0)
			"right": pos = Vector2(-5, 0)
		"idle aim side down fire": match facing:
			"right": pos = Vector2(-1, 0)
		"morph ball", "from morph", "to morph": pos = Vector2(0, 11)
			
	
	# Set the position from which beams, missiles, etc will appear
	var shot_pos = Vector2(0, 0)
	match anim:
		"idle", "idle fire": shot_pos = Vector2(22, -3)
		"run fire", "run": shot_pos = Vector2(24, -3.75)
		"idle aim side up", "idle aim side up fire": shot_pos = Vector2(19, -24)
		"idle aim side down", "idle aim side down fire": shot_pos = Vector2(19, 11)
		"idle aim up", "idle aim up fire": shot_pos = Vector2(5, -32)
		
		"crouch": shot_pos = Vector2(20, 2)
		"crouch fire": shot_pos = Vector2(20, 1)
		"crouch aim up", "crouch aim up fire": shot_pos = Vector2(18, -20)
		"crouch aim down", "crouch aim down fire": shot_pos = Vector2(18, 15)
		
		"run aim up": shot_pos = Vector2(23, -22)
		"run aim down": shot_pos = Vector2(23, 8)

	shot_pos += pos

	if facing == "right" and not anim in ["morph ball", "to morph"]:
		pos.x += 7
		shot_pos.x += 7	
	elif facing == "left":
		shot_pos.x *= -1
		
		if anim in ["idle aim up", "idle aim up fire"]:
			shot_pos.x += 8


	var all_sprites = [$RightSpriteArmed, $RightSpriteUnarmed, $LeftSpriteArmed, $LeftSpriteUnarmed]

	# Apply the animation to all sprites
	for sprite in all_sprites:
		sprite.animation = anim
		sprite.position = pos
		
		# Apply the animation's frame if set earlier
		if anim_frame != 0:
			sprite.frame = anim_frame
			
	
			
	$ShotLocation.position = shot_pos
	


func turnAnimation(anim):
	var turnAnimations = {
		"idle turn": ["run", "idle", "idle fire", "run fire"],
		"idle aim up turn": ["idle aim up", "idle aim up fire"],
		"idle aim side up turn": ["idle aim side up", "idle aim side up fire"],
		"idle aim side down turn": ["idle aim side down", "idle aim side down fire"],
		"crouch turn": ["crouch", "crouch fire"],
		"crouch aim up turn": ["crouch aim up", "crouch aim up fire"],
		"crouch aim down turn": ["crouch aim down", "crouch aim down fire"],
		"to morph": ["crouch"],
		"from morph": ["morph ball"],
		"rising start": ["crouch", "run", "idle", "idle aim up", "idle aim side up", "idle aim side down", "run aim up", "run aim down"]
	}

	if $LeftSpriteUnarmed.animation in turnAnimations[anim]:
		awaiting_animation = true
		playAnimation(anim)
		
		var cooldown_time = 0
		match anim:
			"crouch turn", "crouch aim up turn", "crouch aim down turn": cooldown_time = 0.125
		
		if cooldown_time > 0:
			yield($LeftSpriteUnarmed, "animation_finished")
			$TurnAnimationCooldown.start(cooldown_time)

func decorAnim(anim):
	var temp = $LeftSpriteUnarmed.animation
	playAnimation(anim)
	decor_anim = temp
	
func _on_LeftSprite_animation_finished():
	if awaiting_animation:
		awaiting_animation = false
	
	if decor_anim != null:
		var temp = decor_anim
		decor_anim = null
		playAnimation(temp)
		
func setSpriteVisibility():
	
	# If Samus is facing right, show the RightSprite and hide the LeftSprite (and vice-versa)
	# Also toggles between armed and unarmed sprites
	match facing:
		"right": 
			$LeftSpriteArmed.visible = false
			$LeftSpriteUnarmed.visible = false
			match arming_weapon:
				true:
					$RightSpriteArmed.visible = true
					$RightSpriteUnarmed.visible = false
				false:
					$RightSpriteArmed.visible = false
					$RightSpriteUnarmed.visible = true
			
		"left":
			$RightSpriteArmed.visible = false
			$RightSpriteUnarmed.visible = false
			match arming_weapon:
				true:
					$LeftSpriteArmed.visible = true
					$LeftSpriteUnarmed.visible = false
				false:
					$LeftSpriteArmed.visible = false
					$LeftSpriteUnarmed.visible = true
		
		
		
func cycleWeapon(mode:String, opt:bool):
	
	var weapons: Array
	
	match opt:
		true: weapons = GLOBAL.selectable_weapons_morph
		false: weapons = GLOBAL.selectable_weapons
	
	if mode == "cancel":
		if len(weapons) == 0:
			selected_weapon = null
		else:
			selected_weapon = 0
	elif mode == "next":
		
		if len(weapons) == 0:
			selected_weapon = null
		elif selected_weapon == len(weapons) - 1:
			selected_weapon = 0
		else:
			selected_weapon += 1
	elif mode == "arm":
		HUD.armWeapon(opt)
			
	if mode != "arm":
		HUD.selectWeapon(selected_weapon, opt)
