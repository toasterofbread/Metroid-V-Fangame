extends Area2D

var type: Array
var direction: String
var velocity = "" 
var run_physics = true
var speed = ""

var node = self

const beam_fired_animation = preload("res://Assets/Sprites/Samus/Weapons/Beam fired animation.tres")

const shot_speeds = {
	"missile": 350,
	"super missile": 300,
	"beam": 400,
	"charge beam": 50
}


# Called when the node enters the scene tree for the first time.
func _ready():

	$CollisionShape2D.rotation_degrees = 0
	
	# Set the shot's velocity
	var main = type[0]
	if main in ["missile", "super missile"]:
		speed = shot_speeds[main]
	elif "charge beam" in type:
		speed = shot_speeds["charge beam"]
	else:
		speed = shot_speeds["beam"]
		
	$AnimatedSprite.animation = main
		
	# Set particle effects
	if not main in ["missile", "super missile"]:
		$Particles/BeamTrail.emitting = true
	else:
		$Particles/BeamTrail.emitting = false
		$Timers/TimerB.start()
	
	# Set the shot's rotation
	match direction:
		"up": 
			rotation_degrees = 0
			velocity = Vector2(0, -speed)
		"up right": 
			rotation_degrees = 45
			velocity = Vector2(speed, -speed)

		"right": 
			rotation_degrees = 90
			velocity = Vector2(speed, 0)
		"down right": 
			rotation_degrees = 135
			velocity = Vector2(speed, speed)
		
		"down": 
			rotation_degrees = 180
			velocity = Vector2(0, speed)
		"down left": 
			rotation_degrees = 225
			velocity = Vector2(-speed, speed)
		
		"left": 
			rotation_degrees = 270
			velocity = Vector2(-speed, 0)
		"up left": 
			rotation_degrees = 315
			velocity = Vector2(-speed, -speed)
			
			
	# Apply Samus's velocity to the shot
	velocity += (get_parent().get_node("Samus").velocity * (velocity / speed)) / 3
	
	# Add the beam fired effect
	if main == "beam":
		
		node = AnimatedSprite.new()
		node.frames = beam_fired_animation
		node.animation = "default"
		node.scale = Vector2(0.7, 0.7)
		get_parent().get_node("Samus").add_child(node)
		node.position = get_parent().get_node("Samus/ShotLocation").position - (velocity / speed) * 6
		node.playing = true
		
		yield(node, "animation_finished")
		
		node.queue_free()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if run_physics:
		# Move the shot by its velocity, taking delta into account
		translate(velocity * delta)


func _on_shotScene_body_entered(body):

	if not run_physics or "World Block" in body.get_parent().name:
		return

	run_physics = false
	$Particles/MissileTrail.emitting = false
	$Particles/BeamTrail.queue_free()
	$CollisionShape2D.queue_free()
	rotation_degrees = 0
	
	$AnimatedSprite.animation = type[0] + " impact"
	$AnimatedSprite.scale = Vector2(1.2, 1.2)
	$Timers/TimerA.start()
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.visible = false
	yield($Timers/TimerA, "timeout")

	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	
	if "missile" in $AnimatedSprite.animation:
		$Timers/TimerA.start()
		yield($Timers/TimerA, "timeout")

	queue_free()


func _on_TimerB_timeout():
	if run_physics:
		$Particles/MissileTrail.emitting = true


func _on_shotScene_area_entered(area):

	
	if "World Block" in area.get_parent().name and run_physics:
		run_physics = false
		area.get_parent().handleShot(type)
		
		$Particles/MissileTrail.emitting = false
		$Particles/BeamTrail.queue_free()
		$CollisionShape2D.queue_free()
		rotation_degrees = 0
		
		$AnimatedSprite.animation = type[0] + " impact"
		$AnimatedSprite.scale = Vector2(1.2, 1.2)
		$Timers/TimerA.start()
		yield($AnimatedSprite, "animation_finished")
		$AnimatedSprite.visible = false
		yield($Timers/TimerA, "timeout")
	
		queue_free()
