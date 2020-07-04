extends Node2D


func _ready():
	pass


func dialogue():
	
	$Dialogbox.output([["adam start"], 
	
	["adam text", "Samus, we are approaching our destination."], 
	["adam text", "Please prepare for landing at the mining facility."], 
	
	["adam end"]])
	
	yield($Dialogbox, "finished_action")

	yield($Dialogbox, "finished_script")
	$AnimationPlayer.play("fade in black")
