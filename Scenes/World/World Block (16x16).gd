extends Node2D

export var destruction_type: String
export var time_to_reappear: float = -1

const type_rules = {
	"beam": ["beam", "missile", "bomb", "power bomb", "super missile", "screw attack", "speed booster"],
	"bomb": ["bomb", "power bomb"],
	"missile": ["missile", "super missile"],
	"super missile": ["super missile"],
	"screw attack": ["screw attack"],
	"power bomb": ["power bomb"]
}


func _ready():
	
	if destruction_type:
		$BehaviourTexture.animation = destruction_type
		
		
	if time_to_reappear > 0:
		$ReappearTimer.wait_time = time_to_reappear
		

func handleShot(shot_type):

	if not destruction_type:
		return

	if shot_type[0] in type_rules[destruction_type]:

		$MainTexture.visible = false
	
		$BehaviourTexture.play("destruction")
		yield($BehaviourTexture, "animation_finished")

		$BehaviourTexture.stop()
		$BehaviourTexture.visible = false
		
		$Area2D/CollisionShape2D.disabled = true
		$StaticBody2D/CollisionShape2D.disabled = true
		
		if time_to_reappear > 0:
			$ReappearTimer.start()
		
	elif "bomb" in shot_type[0] and $MainTexture.visible:
		$MainTexture.visible = false


func _on_ReappearTimer_timeout():
	$Area2D/CollisionShape2D.disabled = false
	$BehaviourTexture.visible = true
	
	$BehaviourTexture.play("reappear")
	yield($BehaviourTexture, "animation_finished")
	$BehaviourTexture.stop()
	
	if $Area2D.overlaps_body(get_parent().get_parent().get_node("Samus")):
		$Area2D/CollisionShape2D.disabled = true
		$BehaviourTexture.play("destruction")
		yield($BehaviourTexture, "animation_finished")
		$BehaviourTexture.visible = false
		$ReappearTimer.start()
	else:
		$BehaviourTexture.animation = destruction_type
		$StaticBody2D/CollisionShape2D.disabled = false
	

