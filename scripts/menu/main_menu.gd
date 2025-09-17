# main_menu.gd
extends Control

# Referencias a los nodos del menú
@onready var characters: AnimatedSprite2D = $Characters

func _ready() -> void:
	print("=== MAIN MENU INICIADO ===")
	print("Nodo tipo: ", get_class())
	print("Nombre del nodo: ", name)
	MusicPlayer.play_music("menu_theme")
	
	if characters:
		characters.play()
		print("Characters animándose correctamente")
	else:
		print("ERROR: No se encontró el nodo Characters")
	
	print("Menú principal cargado. Presiona SPACE para continuar.")
	print("============================")

func _input(event: InputEvent) -> void:
	# Detectar cuando se hace clic o presiona SPACE
	if event.is_action_pressed("jump") and not SceneTransition.is_transitioning:
		print("¡¡¡ SPACE PRESIONADO !!!")
		print("Yendo al menú de navegación con botones...")
		
		# Ir al start_menu que tiene los botones funcionales
		SceneTransition.circular_transition_to("res://scenes/ui/start_menu.tscn")
