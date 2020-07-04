extends Node2D

export var text_can_be_sped_up = true
const dialogue_one = "After narrowly escaping the station, I went into hiding with nothing but my weakened suit,"
const dialogue_two = "ship, and the creatures that had brought that ship to my rescue during the escape."
const dialogue_three = "I was quickly forced to sell much of my equipment at a remote supply station in exchange for food and fuel."

const dialogue_four = "As I was searching for a safe location to land and make repairs to my ship, the ship’s scanners detected an abandoned mining facility on a small asteroid far outside the Federation’s territory.\n\nHoping to find useful equipment left behind by the miners, I decided to travel there."

var next_scene = preload("res://Scenes/Levels/Opening/OpeningScene4.tscn")
var scene = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Text.visible_characters = 0
	$Outline.visible_characters = 0
	$AnimationPlayer.play("fade from white")
	yield($AnimationPlayer, "animation_finished")
	output()

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_accept") and $NextTriangle.visible:
		
		$NextTriangle.visible = false
		
		if scene == 1:
			scene = 2
			
			$Text.visible_characters = 0
			$Outline.visible_characters = 0
			
			output()
		elif scene == 2:
			scene = 3
			
			$Text.visible_characters = 0
			$Outline.visible_characters = 0
			
			output()
		elif scene == 3:
			scene = 4
			
			$AnimationPlayer.play("fade to black")
			
			yield($AnimationPlayer, "animation_finished")
			
			$BG.play("cockpit")
			$ReadabilityLayer.visible = true
			$Ship.visible = false
			
			$Text.rect_position.y -= 150
			$Outline.rect_position.y -= 150
			
			$Text.rect_size.y = 500
			$Outline.rect_size.y = 500
			
			$Text.visible_characters = 0
			$Outline.visible_characters = 0
			
			$AnimationPlayer.play("fade from black")
			
			yield($AnimationPlayer, "animation_finished")
			output()
		elif scene == 4:
			$AnimationPlayer.play("fade to black")
			yield($AnimationPlayer, "animation_finished")
			get_tree().change_scene_to(next_scene)
	
	if Input.is_action_pressed("ui_cancel") and text_can_be_sped_up:
		$TextSpeed.wait_time = 0.01
	else:
		$TextSpeed.wait_time = 0.075

func output():
	
	$Text.visible_characters = 0
	$Outline.visible_characters = 0
	
	var dia = ""
	
	match scene:
		1: dia = dialogue_one
		2: dia = dialogue_two
		3: dia = dialogue_three
		4: dia = dialogue_four

		
	$Text.text = dia
	$Outline.text = dia
	
	$TextSpeed.start()
	
	for c in dia:
		
		$Text.visible_characters += 1
		$Outline.visible_characters += 1
		yield($TextSpeed, "timeout")
		
	$TextSpeed.stop()
	$NextTriangle.visible = true
