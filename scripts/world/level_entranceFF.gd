extends Area2D

@export var level_scene_path: String
@onready var interaction_prompt = $InteractionPrompt

var player_is_near = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if interaction_prompt:
		interaction_prompt.visible = false

func _on_body_entered(body):
	if body is CharacterBody2D:
		if interaction_prompt:
			interaction_prompt.visible = true
		player_is_near = true

func _on_body_exited(body):
	if body is CharacterBody2D:
		if interaction_prompt:
			interaction_prompt.visible = false
		player_is_near = false

func _process(_delta):
	if player_is_near and Input.is_action_just_pressed("ui_accept"):
		enter_level()

func enter_level():
	MusicPlayer.force_play_music("floral_fury")
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
