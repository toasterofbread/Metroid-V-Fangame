extends Node2D

signal samus_ready
export var opening = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if opening:
		$Samus.starting_animation = "idle"
		$Samus.start_without_physics = true
		$Samus.visible = false
		
		$AnimationPlayer.play("New Anim")
		
		
	emit_signal("samus_ready")
		
		

func _physics_process(delta):
	
	if opening and $AnimationPlayer.is_playing():
		$Samus.global_position = $Ship.global_position
