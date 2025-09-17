extends Node

@onready var music_stream_player = $MusicStreamPlayer
@onready var sfx_stream_player = $SFXStreamPlayer

var music_tracks = {
	"menu_theme": preload("res://assets/audio/music/01. Don't Deal With the Devil.mp3"),
	"map_theme": preload("res://assets/audio/music/06. Inkwell Isle One.mp3"),
	"floral_fury": preload("res://assets/audio/music/13. Floral Fury.mp3")
}

var sfx_tracks = {
	"swell_battle": preload("res://assets/audio/sfx/a-good-day-for-a-swell-battle.mp3"),
	"level_announcer": preload("res://assets/audio/sfx/sfx_level_announcer_0002_c-online-audio-converter.mp3")
}

var current_track_name = null

func play_music(track_name):
	if not music_tracks.has(track_name):
		return

	if track_name == current_track_name and music_stream_player.playing:
		return

	if music_stream_player.playing:
		music_stream_player.stop()
	
	music_stream_player.stream = music_tracks[track_name]
	music_stream_player.play()
	current_track_name = track_name

func force_play_music(track_name):
	if not music_tracks.has(track_name):
		return

	if music_stream_player.playing:
		music_stream_player.stop()
	
	music_stream_player.stream = music_tracks[track_name]
	music_stream_player.play()
	current_track_name = track_name

func stop_music():
	music_stream_player.stop()
	current_track_name = null

func play_sfx(sfx_name):
	if not sfx_tracks.has(sfx_name):
		return
	
	sfx_stream_player.stream = sfx_tracks[sfx_name]
	sfx_stream_player.play()

func play_level_start_sequence():
	play_sfx("swell_battle")
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2.5
	timer.one_shot = true
	timer.timeout.connect(_play_level_announcer)
	timer.start()

func _play_level_announcer():
	play_sfx("level_announcer")
