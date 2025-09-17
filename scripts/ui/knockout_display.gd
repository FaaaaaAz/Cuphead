extends CanvasLayer

@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer

var is_showing_knockout = false

func _ready():
	visible = false
	
	if audio_player:
		audio_player.stream = preload("res://assets/audio/sfx/Voicy_ Knockout SFX.mp3")
		audio_player.volume_db = 0
	
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)

func show_knockout():
	if is_showing_knockout:
		return
	
	is_showing_knockout = true
	
	visible = true
	
	if audio_player:
		audio_player.play()
	
	if animated_sprite:
		animated_sprite.play("play")
	
	if not animated_sprite:
		await get_tree().create_timer(3.0).timeout
		hide_knockout()

func _on_animation_finished():
	await get_tree().create_timer(1.0).timeout
	hide_knockout()

func hide_knockout():
	visible = false
	is_showing_knockout = false
	
	if animated_sprite:
		animated_sprite.stop()
	
	if audio_player:
		audio_player.stop()
