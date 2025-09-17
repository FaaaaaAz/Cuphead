extends Node

# Referencias a nuestros reproductores de audio
@onready var music_stream_player = $MusicStreamPlayer
@onready var sfx_stream_player = $SFXStreamPlayer

# Diccionario con tus canciones específicas
var music_tracks = {
	"menu_theme": preload("res://assets/audio/music/01. Don't Deal With the Devil.mp3"),
	"map_theme": preload("res://assets/audio/music/06. Inkwell Isle One.mp3"),
	"floral_fury": preload("res://assets/audio/music/13. Floral Fury.mp3")
}

# Diccionario con efectos de sonido
var sfx_tracks = {
	"swell_battle": preload("res://assets/audio/sfx/a-good-day-for-a-swell-battle.mp3"),
	"level_announcer": preload("res://assets/audio/sfx/sfx_level_announcer_0002_c-online-audio-converter.mp3")
}

# Variable para saber qué canción está sonando
var current_track_name = null

# Función para reproducir música
func play_music(track_name):
	# Verificamos que la canción exista en nuestro diccionario
	if not music_tracks.has(track_name):
		print("❌ MusicPlayer ERROR: La canción '", track_name, "' no se encuentra en music_tracks.")
		return

	# Si ya está sonando la canción que pides Y el reproductor está activo, no hacemos nada
	if track_name == current_track_name and music_stream_player.playing:
		return

	# Detener música anterior si hay alguna
	if music_stream_player.playing:
		music_stream_player.stop()
	
	# Asignamos la nueva canción al reproductor y la iniciamos
	music_stream_player.stream = music_tracks[track_name]
	music_stream_player.play()
	
	# Actualizamos el nombre de la canción que está sonando
	current_track_name = track_name

# Función para forzar el cambio de música (sin verificaciones)
func force_play_music(track_name):
	# Verificamos que la canción exista en nuestro diccionario
	if not music_tracks.has(track_name):
		print("❌ MusicPlayer ERROR: La canción '", track_name, "' no se encuentra en music_tracks.")
		return

	# Detener música anterior si hay alguna
	if music_stream_player.playing:
		music_stream_player.stop()
	
	# Asignamos la nueva canción al reproductor y la iniciamos
	music_stream_player.stream = music_tracks[track_name]
	music_stream_player.play()
	
	# Actualizamos el nombre de la canción que está sonando
	current_track_name = track_name

# Función para detener la música si es necesario (opcional)
func stop_music():
	music_stream_player.stop()
	current_track_name = null

# Función para reproducir efectos de sonido
func play_sfx(sfx_name):
	if not sfx_tracks.has(sfx_name):
		print("❌ SFX ERROR: El efecto '", sfx_name, "' no existe.")
		return
	
	sfx_stream_player.stream = sfx_tracks[sfx_name]
	sfx_stream_player.play()

# Función especial para la secuencia de inicio del nivel
func play_level_start_sequence():
	# Primero reproducir "A good day for a swell battle"
	play_sfx("swell_battle")
	
	# Crear un temporizador para reproducir el segundo sonido después del primero
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.5  # 2.5 segundos de espera
	timer.one_shot = true
	timer.timeout.connect(_play_level_announcer)
	timer.start()

func _play_level_announcer():
	play_sfx("level_announcer")
