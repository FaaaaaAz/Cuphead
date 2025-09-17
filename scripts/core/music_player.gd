extends Node

# Una referencia a nuestro reproductor de audio
@onready var music_stream_player = $MusicStreamPlayer

# Diccionario con tus canciones específicas
var music_tracks = {
	"menu_theme": preload("res://assets/audio/music/01. Don't Deal With the Devil.mp3"),
	"map_theme": preload("res://assets/audio/music/06. Inkwell Isle One.mp3"),
	"floral_fury": preload("res://assets/audio/music/13. Floral Fury.mp3")
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
