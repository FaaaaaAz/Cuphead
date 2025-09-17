# story_manager.gd
extends Control

# Configuración de la historia
@export var auto_advance_time: float = 3.0  # Tiempo automático entre frames
@export var enable_auto_advance: bool = false  # ¿Avanzar automáticamente?
@export var story_folder: String = "res://assets/art/pages_history/"
@export var next_scene_after_story: String = "res://scenes/ui/main_menu.tscn"

# Referencias a nodos
@onready var story_image: TextureRect = $StoryImage
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var instructions: Label = $UI/Instructions
@onready var timer: Timer = $Timer

# Variables del sistema
var story_frames: Array[String] = []
var current_frame: int = 0
var total_frames: int = 0

func _ready():
	print("=== INICIANDO SISTEMA DE HISTORIA ===")
	load_story_frames()
	setup_ui()
	show_current_frame()
	
	# Configurar timer si está habilitado el avance automático
	if enable_auto_advance:
		timer.wait_time = auto_advance_time
		timer.start()

func load_story_frames():
	"""Cargar automáticamente todas las imágenes de la historia"""
	var dir = DirAccess.open(story_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Solo archivos PNG que no sean .import
			if file_name.ends_with(".png") and not file_name.ends_with(".import"):
				story_frames.append(story_folder + file_name)
				print("Frame encontrado: ", file_name)
			file_name = dir.get_next()
		
		# Ordenar numéricamente (1.png, 2.png, 3.png...)
		story_frames.sort_custom(sort_frames_numerically)
		total_frames = story_frames.size()
		
		print("Total de frames cargados: ", total_frames)
		for i in range(story_frames.size()):
			print("Frame ", i + 1, ": ", story_frames[i])
	else:
		print("ERROR: No se pudo abrir la carpeta: ", story_folder)

func sort_frames_numerically(a: String, b: String) -> bool:
	"""Ordenar archivos numéricamente para diferentes formatos de nombres"""
	var a_name = a.get_file().get_basename()
	var b_name = b.get_file().get_basename()
	
	# Buscar números al final del nombre usando regex más flexible
	var regex = RegEx.new()
	regex.compile(r"(\d+)$")
	
	var a_result = regex.search(a_name)
	var b_result = regex.search(b_name)
	
	# Si ambos tienen números al final, comparar numéricamente
	if a_result and b_result:
		var a_num = a_result.get_string().to_int()
		var b_num = b_result.get_string().to_int()
		return a_num < b_num
	else:
		# Para casos especiales manejar diferentes prefijos
		var a_has_turn = "turn" in a_name
		var b_has_turn = "turn" in b_name
		var a_is_base = not a_has_turn and not "intro" in a_name and not "outro" in a_name
		var b_is_base = not b_has_turn and not "intro" in b_name and not "outro" in b_name
		
		# Priorizar archivos base (book_p1_0000) antes que archivos turn
		if a_is_base and b_has_turn:
			return true
		elif a_has_turn and b_is_base:
			return false
		else:
			# Fallback a comparación alfabética
			return a_name < b_name

func setup_ui():
	"""Configurar la interfaz de usuario"""
	if total_frames > 0:
		progress_bar.max_value = total_frames
		progress_bar.value = 1
		
		# Actualizar instrucciones según el modo y cantidad de frames
		if enable_auto_advance:
			if total_frames > 50:
				instructions.text = "Introducción animada | Click para acelerar | ESC para saltar"
			else:
				instructions.text = "Historia automática | Click para avanzar | ESC para saltar"
		else:
			instructions.text = "Click para continuar | ESC para saltar historia"
		
		print("=== CONFIGURACIÓN DE UI ===")
		print("Total de frames: ", total_frames)
		print("Modo automático: ", enable_auto_advance)
		print("Tiempo por frame: ", auto_advance_time, " segundos")
		if enable_auto_advance:
			var total_time = total_frames * auto_advance_time
			print("Duración total estimada: ", total_time, " segundos (", total_time / 60.0, " minutos)")
	else:
		instructions.text = "Error: No se encontraron imágenes de historia"

func show_current_frame():
	"""Mostrar el frame actual"""
	if current_frame < total_frames and current_frame >= 0:
		var texture_path = story_frames[current_frame]
		var texture = load(texture_path)
		
		if texture:
			story_image.texture = texture
			progress_bar.value = current_frame + 1
			print("Mostrando frame ", current_frame + 1, "/", total_frames, ": ", texture_path)
		else:
			print("ERROR: No se pudo cargar la textura: ", texture_path)
	else:
		print("Historia completada")
		end_story()

func _input(event):
	"""Manejar entrada del usuario"""
	# ESC para saltar toda la historia
	if event.is_action_pressed("ui_cancel"):
		print("Historia saltada por el usuario")
		end_story()
		return
	
	# Click o Enter para avanzar manualmente o acelerar automático
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		if enable_auto_advance:
			# Si está en modo automático, acelerar la velocidad
			var new_time = max(0.05, auto_advance_time * 0.5)  # No menos de 0.05 segundos
			timer.wait_time = new_time
			print("Acelerando animación: ", auto_advance_time, " -> ", new_time, " segundos por frame")
		else:
			# Si está en modo manual, avanzar normalmente
			advance_frame()

func advance_frame():
	"""Avanzar al siguiente frame"""
	current_frame += 1
	
	if current_frame < total_frames:
		show_current_frame()
		
		# Reiniciar timer si está en modo automático
		if enable_auto_advance and timer:
			timer.start()
	else:
		end_story()

func _on_timer_timeout():
	"""Callback del timer para avance automático"""
	if enable_auto_advance:
		advance_frame()

func end_story():
	"""Terminar la historia y ir a la siguiente escena"""
	print("=== HISTORIA TERMINADA ===")
	print("Cambiando a: ", next_scene_after_story)
	
	# Pequeña pausa antes de cambiar escena
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(next_scene_after_story)

# Funciones públicas para configurar desde el exterior
func set_auto_advance(enabled: bool, time: float = 3.0):
	"""Configurar avance automático"""
	enable_auto_advance = enabled
	auto_advance_time = time
	if timer:
		timer.wait_time = time

func set_next_scene(scene_path: String):
	"""Configurar la escena siguiente"""
	next_scene_after_story = scene_path

func set_story_folder(folder_path: String):
	"""Configurar carpeta de imágenes"""
	story_folder = folder_path
