# scene_transition.gd
extends Control

# Nodo singleton para manejar transiciones entre escenas

var transition_duration: float = 2.0
var is_transitioning: bool = false

# Referencias
@onready var color_rect: ColorRect

func _ready() -> void:
	# Configurar el nodo como overlay
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Crear ColorRect para la transición
	color_rect = ColorRect.new()
	add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.BLACK
	color_rect.color.a = 0.0  # Empezar transparente
	
	# Inicialmente invisible
	hide()
	
	print("SceneTransition singleton inicializado correctamente")

func fade_transition_to(scene_path: String) -> void:
	"""Transición simple de fade"""
	if is_transitioning:
		print("Ya hay una transición en progreso")
		return
		
	is_transitioning = true
	show()
	
	print("Iniciando transición fade a: ", scene_path)
	
	var tween = create_tween()
	
	# Fade out
	print("Fade out...")
	tween.tween_property(color_rect, "color:a", 1.0, 0.8)
	
	# Cambiar escena
	tween.tween_callback(func(): 
		print("Cambiando escena...")
		get_tree().change_scene_to_file(scene_path)
	)
	
	# Esperar que cargue la nueva escena
	tween.tween_interval(0.2)
	
	# Fade in
	print("Fade in...")
	tween.tween_property(color_rect, "color:a", 0.0, 0.8)
	
	# Terminar transición
	tween.tween_callback(finish_transition)

func curtain_transition_to(scene_path: String) -> void:
	"""Transición de cortina desde los lados"""
	if is_transitioning:
		print("Ya hay una transición en progreso")
		return
		
	is_transitioning = true
	show()
	
	print("Iniciando transición de cortina a: ", scene_path)
	
	# Crear cortinas izquierda y derecha
	var left_curtain = ColorRect.new()
	var right_curtain = ColorRect.new()
	
	add_child(left_curtain)
	add_child(right_curtain)
	
	# Configurar cortinas
	left_curtain.color = Color.BLACK
	right_curtain.color = Color.BLACK
	
	var screen_size = get_viewport().get_visible_rect().size
	
	# Cortina izquierda - empieza fuera de pantalla
	left_curtain.position = Vector2(-screen_size.x / 2, 0)
	left_curtain.size = Vector2(screen_size.x / 2, screen_size.y)
	
	# Cortina derecha - empieza fuera de pantalla 
	right_curtain.position = Vector2(screen_size.x, 0)
	right_curtain.size = Vector2(screen_size.x / 2, screen_size.y)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Cerrar cortinas
	print("Cerrando cortinas...")
	tween.tween_property(left_curtain, "position:x", 0, 0.8)
	tween.tween_property(right_curtain, "position:x", screen_size.x / 2, 0.8)
	
	# Esperar que las cortinas se cierren
	tween.tween_interval(0.8)
	
	# Cambiar escena
	tween.tween_callback(func(): 
		print("Cambiando escena...")
		get_tree().change_scene_to_file(scene_path)
	)
	
	# Esperar carga
	tween.tween_interval(0.2)
	
	# Abrir cortinas
	print("Abriendo cortinas...")
	tween.tween_property(left_curtain, "position:x", -screen_size.x / 2, 0.8)
	tween.tween_property(right_curtain, "position:x", screen_size.x, 0.8)
	
	# Limpiar y terminar
	tween.tween_callback(func(): 
		left_curtain.queue_free()
		right_curtain.queue_free()
		finish_transition()
	)

func circular_transition_to(scene_path: String) -> void:
	"""Transición circular con shader"""
	if is_transitioning:
		print("Ya hay una transición en progreso")
		return
		
	is_transitioning = true
	show()
	
	print("Iniciando transición circular a: ", scene_path)
	
	# Crear círculo con shader
	var circle_rect = ColorRect.new()
	add_child(circle_rect)
	circle_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	circle_rect.color = Color.BLACK
	
	# Configurar shader
	var material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float radius : hint_range(0.0, 2.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
	vec2 uv = UV;
	float dist = distance(uv, center);
	float max_dist = 0.8;
	
	if (dist > radius * max_dist) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}
"""
	material.shader = shader
	material.set_shader_parameter("radius", 2.0)
	circle_rect.material = material
	
	var tween = create_tween()
	
	# Cerrar círculo
	print("Cerrando círculo...")
	tween.tween_method(
		func(value): material.set_shader_parameter("radius", value),
		2.0, 0.0, 0.8
	)
	
	# Cambiar escena
	tween.tween_callback(func(): 
		print("Cambiando escena...")
		get_tree().change_scene_to_file(scene_path)
	)
	
	# Esperar carga
	tween.tween_interval(0.2)
	
	# Abrir círculo
	print("Abriendo círculo...")
	tween.tween_method(
		func(value): material.set_shader_parameter("radius", value),
		0.0, 2.0, 0.8
	)
	
	# Limpiar y terminar
	tween.tween_callback(func(): 
		circle_rect.queue_free()
		finish_transition()
	)

func finish_transition() -> void:
	"""Terminar la transición"""
	is_transitioning = false
	hide()
	print("Transición completada y ocultada")
