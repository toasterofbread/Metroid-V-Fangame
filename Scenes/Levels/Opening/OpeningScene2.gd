extends Node2D

const next_scene = preload("res://Scenes/Levels/Opening/OpeningScene3.tscn")
export var text_can_be_sped_up = true

const dialogue_one = "It was two weeks ago that I encountered and destroyed the Federation’s experimental Metroid labs on the B.S.L research station. Until then, I’d believed that I had finally succeeded in eradicating the galaxy of their kind. The Federation could have had other Metroid labs elsewhere in the galaxy, or individual Metroids that were sent out for service..."

const dialogue_two = "If the Federation’s experiments were truly only for peaceful purposes as Adam, my ship’s computer, believes, then perhaps it can be laid to rest. While I trust Adam, who has adopted the mind of my former mentor, enough on this matter, I still have doubts about the Federation’s honesty about its true intentions..."

var scene = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Black.visible = true
	$Text.visible_characters = 0
	$Outline.visible_characters = 0
	
	yield($AnimationPlayer, "animation_finished")
	
	output()

func _physics_process(_delta):
	
	if Input.is_action_just_pressed("ui_accept") and $NextTriangle.visible:
		
		if scene == 1:
			$NextTriangle.visible = false
			scene = 2
			
			$AnimationPlayer.play("fade to black")
			yield($AnimationPlayer, "animation_finished")
			$LabAnim.play("main")
			yield($LabAnim, "animation_finished")
			$AnimationPlayer.play("fade from black")
			
			$Text.visible_characters = 0
			$Outline.visible_characters = 0
			
			yield($AnimationPlayer, "animation_finished")
			output()
		elif scene == 2:
			$NextTriangle.visible = false
			scene = 3
			
			$AnimationPlayer.play("fade to black")
			yield($AnimationPlayer, "animation_finished")
			$AnimationPlayer.play("fade from black")
			
			$"BSL Destruction".visible = true
			$"BSL Destruction".play()
			yield($"BSL Destruction", "animation_finished")
			get_tree().change_scene_to(next_scene)
		elif scene == 3:
			$NextTriangle.visible = false
			
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
		
	$Text.text = dia
	$Outline.text = dia
	
	$TextSpeed.start()
	
	for c in dia:
		
		$Text.visible_characters += 1
		$Outline.visible_characters += 1
		yield($TextSpeed, "timeout")
		
	$TextSpeed.stop()
	$NextTriangle.visible = true
	
