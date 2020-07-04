extends Control

signal finished_action
signal finished_script
signal continue_dialogue

var accepted = false

export var auto_time: float = -1
export var normal_text_speed: float = 0.1
export var fast_text_speed: float = 0.05
export var can_be_sped_up = true

func _ready():
	
	$CanvasLayer/Adam.visible = false
	$CanvasLayer/Adam.playing = false
	$CanvasLayer/AdamText.text = ""
	$CanvasLayer/AdamTextOutline.text = ""
	
	if auto_time >= 0:
		$AutoTimer.wait_time = auto_time
	
func _physics_process(delta):
	
	if Input.is_action_pressed("ui_cancel") and can_be_sped_up:
		$TextSpeed.wait_time = fast_text_speed
	else:
		$TextSpeed.wait_time = normal_text_speed
		
	if Input.is_action_pressed("ui_accept") and auto_time < 0:
		emit_signal("continue_dialogue")

func output(script:Array):
	

	for action in script:
		
		if action[0] == "adam text":
			
			$CanvasLayer/AdamText.text = ""
			$CanvasLayer/AdamTextOutline.text = ""
			$TextSpeed.start()
			
			var started = false
			for c in action[1]:
				
				if started:
					$CanvasLayer/AdamText.text = $CanvasLayer/AdamText.text.trim_suffix("_")
					$CanvasLayer/AdamTextOutline.text = $CanvasLayer/AdamTextOutline.text.trim_suffix("_")
				else:
					started = true
				
				$CanvasLayer/AdamText.text += c + "_"
				$CanvasLayer/AdamTextOutline.text += c + "_"
				yield($TextSpeed, "timeout")
				
			$CanvasLayer/AdamText.text = $CanvasLayer/AdamText.text.trim_suffix("_")
			$CanvasLayer/AdamTextOutline.text = $CanvasLayer/AdamTextOutline.text.trim_suffix("_")
			$TextSpeed.stop()
			
			if auto_time >= 0:
				$AutoTimer.start()
			
			yield(self, "continue_dialogue")
			
		elif action[0] == "adam start":
			$CanvasLayer/Adam.visible = true
			$CanvasLayer/Adam.play("start")
			$CanvasLayer/Adam.frame = 0
			yield($CanvasLayer/Adam, "animation_finished")
			$CanvasLayer/Adam.play("dialog")
			yield(wait(0.25), "timeout")
			
		elif action[0] == "adam end":
			$CanvasLayer/AdamText.text = ""
			$CanvasLayer/AdamTextOutline.text = ""
			$CanvasLayer/Adam.visible = true
			$CanvasLayer/Adam.play("end")
			$CanvasLayer/Adam.frame = 0
			yield($CanvasLayer/Adam, "animation_finished")
			$CanvasLayer/Adam.visible = false
			
		emit_signal("finished_action")
		

	emit_signal("finished_script")

func wait(time:float=3):
	$TimeBetweenActions.wait_time = time
	$TimeBetweenActions.start()
	return $TimeBetweenActions


func _on_AutoTimer_timeout():
	emit_signal("continue_dialogue")
