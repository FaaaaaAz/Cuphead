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
	menu_items = [sonido_button, visual_button, controles_button, idioma_button, volver_button]
	
	for i in range(menu_items.size()):
		var button = menu_items[i]
		if button:
			button.connect("pressed", _on_button_pressed.bind(i))
	
	_setup_animations()

func _setup_animations():
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
			
			var tween = create_tween()
			if i > 0:
				tween.tween_interval(i * 0.1)
			tween.parallel().tween_property(button, "modulate:a", 1.0, 0.3)
			tween.parallel().tween_property(button, "position:x", original_x, 0.3)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_go_back_to_main_menu()

func _on_button_pressed(button_index: int):
	match button_index:
		0:
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			_go_back_to_main_menu()

func _go_back_to_main_menu():
	var main_menu_path = "res://scenes/ui/start_menu.tscn"
	if ResourceLoader.exists(main_menu_path):
		get_tree().call_deferred("change_scene_to_file", main_menu_path)
