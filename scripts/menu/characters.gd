extends AnimatedSprite2D

# Esta función se ejecuta cuando el nodo está listo
func _ready() -> void:
	# Iniciar la animación automáticamente
	play()
	
	# Opcional: configurar la animación en loop si no está ya configurado
	# (esto se puede hacer también desde el editor de Godot)
	if not sprite_frames.get_animation_loop("default"):
		sprite_frames.set_animation_loop("default", true)
