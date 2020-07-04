extends AnimatedSprite

func _ready():
	$Emission.visible = true

func _physics_process(delta):
	
	var emission = [Vector2(0, 0), Vector2(0 ,0)]
	
	match frame:
		0: emission = [Vector2(0, -4), Vector2(1.062, 1)]
		1: emission = [Vector2(2, -4), Vector2(1.062, 1)]
		2: emission = [Vector2(3, -4), Vector2(1.062, 1)]
		3: emission = [Vector2(5.75, -4), Vector2(1.156, 1)]
		4: emission = [Vector2(6, -4), Vector2(1.156, 1)]
		5: emission = [Vector2(8.375, -5), Vector2(1.203, 1)]
		6: emission = [Vector2(9.688, -5), Vector2(1.289, 1)]
		7: emission = [Vector2(12, -4), Vector2(1.289, 1)]
		8: emission = [Vector2(15, -4), Vector2(1.289, 1)]
		9: emission = [Vector2(20.844, -4), Vector2(1.395, 1)]
		
	
	if flip_h:
		emission[0][0] *= -1
		
	if flip_v:
		emission[0][1] *= -1
		
	$Emission.position = emission[0]
	$Emission.scale = emission[1]


func nextScene():
	queue_free()
