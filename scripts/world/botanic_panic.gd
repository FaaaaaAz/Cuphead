# botanic_panic.gd
extends AnimatedSprite2D

func _ready() -> void:
	# Iniciar animación automáticamente
	play()
	# Asegurar que esté en loop
	sprite_frames.set_animation_loop("default", true)
