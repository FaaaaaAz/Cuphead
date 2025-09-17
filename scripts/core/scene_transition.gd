# scene_transition.gd
extends CanvasLayer

@onready var transition_sprite = $TransitionSprite

var next_scene_path = ""
var is_transitioning = false

func _ready():
	# Conectamos la señal que nos avisará cuando una animación termine
	transition_sprite.animation_finished.connect(_on_animation_finished)
	# Ocultamos el sprite al inicio para que no tape la primera escena
	transition_sprite.hide()
	print("SceneTransition singleton inicializado correctamente")

# Esta es la función que llamaremos desde cualquier parte del juego
func change_scene(scene_path):
	if is_transitioning:
		return  # No hacer nada si ya estamos en transición
	
	is_transitioning = true
	# Hacemos visible el sprite
	transition_sprite.show()
	# Guardamos la ruta de la siguiente escena
	next_scene_path = scene_path
	# Le decimos al sprite que ponga la animación de "cerrar" y la reproduzca
	transition_sprite.play("close")

# Esta función se ejecutará automáticamente cuando termine una animación del sprite
func _on_animation_finished():
	# Obtenemos el nombre de la animación que acaba de terminar
	var anim_name = transition_sprite.animation
	
	# Si la animación que terminó fue la de "cerrar"...
	if anim_name == "close":
		# Es el momento seguro para cambiar de escena
		get_tree().change_scene_to_file(next_scene_path)
		# Y ahora reproducimos la animación de "abrir"
		transition_sprite.play("open")
	
	# Si la que terminó fue la de "abrir", la transición ha finalizado
	elif anim_name == "open":
		# Ocultamos el sprite hasta la próxima vez que lo necesitemos
		transition_sprite.hide()
		is_transitioning = false  # Ya no estamos en transición

# Función de emergencia para resetear el estado
func reset_transition():
	is_transitioning = false
	transition_sprite.hide()
	print("Transición reseteada")

# Función alternativa sin transición (por si acaso)
func circular_transition_to(scene_path):
	change_scene(scene_path)
