extends Control

@onready var health_label: Label = $HealthLabel
@onready var instructions_label: Label = $InstructionsLabel

func _ready() -> void:
	if not health_label:
		health_label = Label.new()
		add_child(health_label)
		health_label.position = Vector2(20, 20)
		health_label.size = Vector2(200, 30)
	
	if not instructions_label:
		instructions_label = Label.new()
		add_child(instructions_label)
		instructions_label.position = Vector2(20, 50)
		instructions_label.size = Vector2(600, 30)
	
	update_instructions()
	update_health(3)

func update_instructions() -> void:
	if instructions_label:
		instructions_label.text = "AD: Mover | SPACE: Saltar | Click: Disparar | ESC: Volver al mapa"

func update_health(health: int) -> void:
	if health_label:
		health_label.text = "Vida: " + str(health)