extends AnimatedSprite2D

func _ready() -> void:
	play()
	sprite_frames.set_animation_loop("default", true)
