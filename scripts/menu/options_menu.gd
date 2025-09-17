extends Control

@onready var sonido_button = $VBoxContainer/SonidoButton
@onready var visual_button = $VBoxContainer/VisualButton  
@onready var controles_button = $VBoxContainer/ControlesButton
@onready var idioma_button = $VBoxContainer/IdiomaButton
@onready var volver_button = $VBoxContainer/VolverButton
@onready var background = $Background

var current_selection = 0
var menu_items = []

func _ready():
	print("=== INICIANDO OPTIONS MENU ===")
	menu_items = [sonido_button, visual_button, controles_button, idioma_button, volver_button]
	
	# Verificar que los nodos existen
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			print("Botón ", i, " encontrado: ", button.name)
		else:
			print("ERROR: Botón ", i, " es null")
	
	# Configurar botones
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			button.connect("pressed", _on_button_pressed.bind(i))
			# Eliminamos la conexión de mouse_entered para que no haya hover
			print("Botón ", i, " configurado correctamente")
	
	# Configurar animaciones
	_setup_animations()
	# Eliminamos _highlight_current_selection() para que no haya resaltado

func _setup_animations():
	# Animación de entrada del menú
	var tween = create_tween()
	modulate.a = 0.0
	scale = Vector2(0.9, 0.9)
	
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_callback(_animate_menu_items)

func _animate_menu_items():
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			button.modulate.a = 0.0
			var original_x = button.position.x
			button.position.x -= 30
			
			# Crear tween con delay usando tween_interval
			var tween = create_tween()
			if i > 0:
				tween.tween_interval(i * 0.1)
			tween.parallel().tween_property(button, "modulate:a", 1.0, 0.3)
			tween.parallel().tween_property(button, "position:x", original_x, 0.3)

func _input(event):
	# Eliminamos toda la navegación por teclado para evitar resaltado
	# Solo mantenemos los clics de mouse
	if event.is_action_pressed("ui_cancel"):
		_go_back_to_main_menu()

func _on_button_pressed(button_index: int):
	print("🎯 BOTÓN DE OPCIONES PRESIONADO - Índice: ", button_index)
	
	match button_index:
		0: # SONIDO
			print("🔊 Configuración de sonido")
			# Aquí puedes agregar lógica para el menú de sonido
		1: # VISUAL
			print("👁️ Configuración visual")
			# Aquí puedes agregar lógica para el menú visual
		2: # CONTROLES
			print("🎮 Configuración de controles")
			# Aquí puedes agregar lógica para el menú de controles
		3: # IDIOMA
			print("🌍 Configuración de idioma")
			# Aquí puedes agregar lógica para el menú de idioma
		4: # VOLVER
			print("🔙 Volviendo al menú principal")
			_go_back_to_main_menu()

func _go_back_to_main_menu():
	var main_menu_path = "res://scenes/ui/start_menu.tscn"
	if ResourceLoader.exists(main_menu_path):
		print("✅ Volviendo al menú principal...")
		get_tree().call_deferred("change_scene_to_file", main_menu_path)
	else:
		print("❌ ERROR: No se encontró start_menu.tscn")
