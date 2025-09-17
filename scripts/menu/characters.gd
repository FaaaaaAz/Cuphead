extends AnimatedSprite2D

func _ready() -> void:
	play()
	
	if not sprite_frames.get_animation_loop("default"):
		sprite_frames.set_animation_loop("default", true)
