extends Node2D

func _ready():
	print("🌻 Nivel Floral Fury iniciado!")
	# Reproducir la secuencia de sonidos al inicio del nivel
	MusicPlayer.play_level_start_sequence()

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		return_to_map()

# Función para volver al mapa con transición
func return_to_map():
	print("🗺️ Volviendo al mapa...")
	# Cambiar la música de vuelta al mapa
	MusicPlayer.play_music("map_theme")
	# Usar transición para volver al mapa
	SceneTransition.change_scene("res://scenes/ui/world_map.tscn")