# player_bullet.gd
extends Area2D

var speed: float = 800.0
var direction: int = 1  # 1 para derecha, -1 para izquierda

func _ready() -> void:
	# Conectar señales si no están conectadas desde el editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# Mueve la bala en la dirección especificada
	position.x += speed * direction * delta
	
	# Destruir la bala si sale de la pantalla (opcional)
	if position.x > 2000 or position.x < -500:
		queue_free()

func set_direction(new_direction: int) -> void:
	"""Cambiar la dirección de la bala"""
	direction = new_direction

func _on_body_entered(body: Node2D) -> void:
	# Esta función se llama sola cuando la bala choca con un cuerpo físico.
	# Verificamos si el cuerpo con el que chocamos está en el grupo "boss".
	if body.is_in_group("boss"):
		# Si es el jefe, llamamos a su función para hacerle daño.
		body.take_damage(1)
	
	# Después de chocar con CUALQUIER cuerpo físico, la bala se destruye.
	queue_free()

func _on_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.
