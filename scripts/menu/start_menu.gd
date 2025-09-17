extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton  
@onready var exit_button = $VBoxContainer/ExitButton
@onready var teacup = $TeaCup
@onready var particles = $ParticleSystem

var current_selection = 0
var menu_items = []

func _ready():
	MusicPlayer.play_music("menu_theme")
	
	if start_button == null or options_button == null or exit_button == null:
		return
		
	menu_items = [start_button, options_button, exit_button]
	
	var imagen_path = "res://assets/art/menu/Background.png"  
	if ResourceLoader.exists(imagen_path):
		teacup.texture = load(imagen_path)
	
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			button.connect("pressed", _on_button_pressed.bind(i))
	
	_setup_animations()

func _setup_animations():
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
		
		var tween = create_tween()
		if i > 0:
			tween.tween_interval(i * 0.2)
		tween.parallel().tween_property(button, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(button, "position:x", original_x, 0.5)

func _input(_event):
	pass

func _on_button_pressed(button_index: int):
	match button_index:
		0:
			var story_path = "res://scenes/ui/intro_story.tscn"
			if ResourceLoader.exists(story_path):
				get_tree().call_deferred("change_scene_to_file", story_path)
			else:
				var world_map_path = "res://scenes/ui/world_map.tscn"
				if ResourceLoader.exists(world_map_path):
					get_tree().call_deferred("change_scene_to_file", world_map_path)
		1:
			var options_path = "res://scenes/ui/options_menu.tscn"
			if ResourceLoader.exists(options_path):
				get_tree().call_deferred("change_scene_to_file", options_path)
		2:
			get_tree().quit()
