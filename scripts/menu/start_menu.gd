extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton  
@onready var exit_button = $VBoxContainer/ExitButton
@onready var teacup = $TeaCup
@onready var particles = $ParticleSystem

var current_selection = 0
var menu_items = []

func _ready():
	print("=== INICIANDO START MENU ===")
	
	# Reproducir música del menú
	MusicPlayer.play_music("menu_theme")
	
	# Verificar que los nodos existen ANTES de agregarlos al array
	print("Verificando nodos...")
	print("StartButton existe: ", start_button != null)
	print("OptionsButton existe: ", options_button != null) 
	print("ExitButton existe: ", exit_button != null)
	
	if start_button == null:
		print("❌ ERROR CRÍTICO: StartButton es null")
		return
	if options_button == null:
		print("❌ ERROR CRÍTICO: OptionsButton es null")
		return
	if exit_button == null:
		print("❌ ERROR CRÍTICO: ExitButton es null")
		return
		
	menu_items = [start_button, options_button, exit_button]
	print("✅ Array de botones creado con ", menu_items.size(), " elementos")
	
	var imagen_path = "res://assets/art/menu/Background.png"  
	if ResourceLoader.exists(imagen_path):
		teacup.texture = load(imagen_path)
		print("✅ Imagen cargada correctamente")
	else:
		print("❌ No se encontró la imagen en: ", imagen_path)
	
	# Configurar botones
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			print("🔌 Conectando botón ", i, " (", button.name, ")")
			button.connect("pressed", _on_button_pressed.bind(i))
			# Eliminamos la conexión de mouse_entered para que no haya hover
			print("✅ Botón ", i, " configurado correctamente")
		else:
			print("❌ ERROR: Botón ", i, " es null")
	
	# Configurar animaciones
	_setup_animations()
	# Eliminamos _highlight_current_selection() para que no haya resaltado

func _setup_animations():
	# Animación de entrada de la taza
	var tween = create_tween()
	teacup.modulate.a = 0.0
	teacup.scale = Vector2(0.8, 0.8)
	
	tween.parallel().tween_property(teacup, "modulate:a", 1.0, 1.0)
	tween.parallel().tween_property(teacup, "scale", Vector2(1.0, 1.0), 1.0)
	tween.tween_callback(_animate_menu_items)

func _animate_menu_items():
	for i in range(menu_items.size()):
		var button = menu_items[i]
		button.modulate.a = 0.0
		var original_x = button.position.x
		button.position.x -= 50
		
		# Crear tween con delay usando tween_interval
		var tween = create_tween()
		if i > 0:
			tween.tween_interval(i * 0.2)
		tween.parallel().tween_property(button, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(button, "position:x", original_x, 0.5)

func _input(event):
	# Eliminamos toda la navegación por teclado para evitar resaltado
	# Solo mantenemos los clics de mouse
	pass

func _on_button_pressed(button_index: int):
	print("🎯🎯🎯 BOTÓN PRESIONADO - Índice: ", button_index, " 🎯🎯🎯")
	print("=== FUNCIÓN _on_button_pressed EJECUTÁNDOSE ===")
	
	match button_index:
		0: # Start Game
			print("🚀 CASO 0: Iniciando juego - Cambiando a world_map")
			var world_map_path = "res://scenes/ui/world_map.tscn"
			print("Verificando si existe: ", world_map_path)
			print("Archivo existe: ", ResourceLoader.exists(world_map_path))
			
			if ResourceLoader.exists(world_map_path):
				print("✅ Archivo encontrado, cargando escena...")
				get_tree().call_deferred("change_scene_to_file", world_map_path)
				print("✅ Cambio de escena solicitado")
			else:
				print("❌ ERROR: No se encontró world_map.tscn")
		1: # Options
			print("⚙️ CASO 1: Abriendo opciones")
			var options_path = "res://scenes/ui/options_menu.tscn"
			print("Verificando si existe: ", options_path)
			print("Archivo existe: ", ResourceLoader.exists(options_path))
			
			if ResourceLoader.exists(options_path):
				print("✅ Archivo encontrado, cargando menú de opciones...")
				get_tree().call_deferred("change_scene_to_file", options_path)
				print("✅ Cambio de escena solicitado")
			else:
				print("❌ ERROR: No se encontró options_menu.tscn")
		2: # Exit
			print("👋 CASO 2: Saliendo del juego")
			get_tree().quit()
		_:
			print("❌ CASO DESCONOCIDO: button_index = ", button_index)
