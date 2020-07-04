extends Node2D

const next_scene = preload("res://Scenes/Levels/Opening/OpeningScene2.tscn")


func nextScene():
	$AnimationPlayer.play("fade to black")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene_to(next_scene)
