extends CharacterBody2D

const SPEED = 100

func _physics_process(delta):
	
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if dir:
		if dir.x != 0:
			if dir.x > 0:
				$Sprite.play("walk_right")
				pass
			else:
				$Sprite.play("walk_left")
				
			pass
		else:
			if dir.y > 0:
				$Sprite.play("walk_down")
				pass
			else:
				$Sprite.play("walk_up")
				
			pass
		pass 
	else:
		$Sprite.stop()
	
	velocity = dir * SPEED
	move_and_slide()
	
	pass
