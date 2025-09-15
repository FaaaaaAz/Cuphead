# map_hud.gd
extends Control

@onready var level_label: Label = $LevelLabel
@onready var instructions_label: Label = $InstructionsLabel

func _ready() -> void:
	# Crear labels si no existen
	if not level_label:
		level_label = Label.new()
		add_child(level_label)
		level_label.position = Vector2(20, 20)
		level_label.size = Vector2(400, 30)
	
	if not instructions_label:
		instructions_label = Label.new()
		add_child(instructions_label)
		instructions_label.position = Vector2(20, 50)
		instructions_label.size = Vector2(600, 60)
	
	# Configurar texto inicial
	update_instructions()

func update_instructions() -> void:
	if instructions_label:
		instructions_label.text = "WASD: Navegar | SPACE/ENTER: Seleccionar nivel | ESC: Volver al menú"

func update_level_name(level_name: String) -> void:
	if level_label:
		level_label.text = "Nivel seleccionado: " + level_name