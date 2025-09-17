extends CanvasLayer

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer

var is_showing_knockout = false

func _ready():
	# Ocultar la escena al inicio
	visible = false
	
	# Configurar el audio
	if audio_player:
		audio_player.stream = preload("res://assets/audio/sfx/Voicy_ Knockout SFX.mp3")
		audio_player.volume_db = 0  # Volumen normal
	
	# Conectar señal de animación terminada
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func show_knockout():
	"""Muestra el efecto KNOCKOUT con animación y sonido"""
	if is_showing_knockout:
		return  # Ya se está mostrando
	
	print("🥊 KNOCKOUT! Mostrando efecto...")
	is_showing_knockout = true
	
	# Hacer visible la escena
	visible = true
	
	# Reproducir sonido
	if audio_player:
		audio_player.play()
	
	# Reproducir animación
	if animated_sprite:
		animated_sprite.play("play")  # Usa la animación "play" que tienes configurada
	
	# Si no hay animación, auto-ocultar después de 3 segundos
	if not animated_sprite:
		await get_tree().create_timer(3.0).timeout
		hide_knockout()

func _on_animation_finished():
	"""Se llama cuando termina la animación del KNOCKOUT"""
	print("✅ Animación KNOCKOUT terminada")
	
	# Esperar un momento más para que se vea bien
	await get_tree().create_timer(1.0).timeout
	
	# Ocultar el knockout
	hide_knockout()

func hide_knockout():
	"""Oculta el efecto KNOCKOUT"""
	print("🎯 Ocultando KNOCKOUT...")
	visible = false
	is_showing_knockout = false
	
	# Parar la animación
	if animated_sprite:
		animated_sprite.stop()
	
	# Parar el audio
	if audio_player:
		audio_player.stop()

# Función de testing removida para evitar crashes
