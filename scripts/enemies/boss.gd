# boss.gd
extends CharacterBody2D

# --- Estados del Boss ---
enum State {
	IDLE,      # Esperando
	ATTACKING, # Atacando
	HURT,      # Recibiendo daño
	DEAD       # Derrotado
}

# --- Variables Exportadas ---
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 1
@export var detection_range: float = 500.0
@export var attack_cooldown: float = 2.0

# --- Variables Internas ---
var current_state: State = State.IDLE
var player_reference: CharacterBody2D = null
var attack_timer: float = 0.0
var facing_right: bool = true

# Referencias a nodos
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer_node: Timer = $AttackTimer
@onready var hurt_area: Area2D = $HurtArea

# Señales
signal boss_died
signal boss_attack

# --- Inicialización ---
func _ready() -> void:
	health = max_health
	
	# Añadir al grupo "boss" para que las balas puedan detectarlo
	add_to_group("boss")
	
	# Configurar timer de ataque
	if attack_timer_node:
		attack_timer_node.wait_time = attack_cooldown
		attack_timer_node.timeout.connect(_on_attack_timer_timeout)
		attack_timer_node.start()
	
	# Configurar área de daño
	if hurt_area:
		hurt_area.body_entered.connect(_on_hurt_area_body_entered)
	
	# Buscar al jugador en la escena
	find_player()

func find_player() -> void:
	"""Buscar al jugador en la escena"""
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_reference = players[0]

# --- Lógica Principal ---
func _physics_process(_delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	# Actualizar comportamiento según el estado
	match current_state:
		State.IDLE:
			idle_behavior()
		State.ATTACKING:
			attack_behavior()
		State.HURT:
			hurt_behavior()

func idle_behavior() -> void:
	"""Comportamiento en estado idle"""
	if player_reference:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		
		# Si el jugador está cerca, prepararse para atacar
		if distance_to_player <= detection_range:
			look_at_player()
			# El ataque se manejará con el timer

func attack_behavior() -> void:
	"""Comportamiento durante ataque"""
	if player_reference:
		look_at_player()
	
	# El ataque durará hasta que el timer termine
	# Aquí podrías añadir animaciones de ataque

func hurt_behavior() -> void:
	"""Comportamiento al recibir daño"""
	# Breve pausa al recibir daño
	pass

func look_at_player() -> void:
	"""Orientar el boss hacia el jugador"""
	if not player_reference:
		return
	
	var should_face_right = player_reference.global_position.x > global_position.x
	
	if should_face_right != facing_right:
		facing_right = should_face_right
		if sprite:
			sprite.flip_h = !facing_right

# --- Sistema de Daño ---
func take_damage(damage: int) -> void:
	"""Recibir daño"""
	if current_state == State.DEAD:
		return
	
	health -= damage
	current_state = State.HURT
	
	print("Boss recibió ", damage, " de daño. Vida restante: ", health)
	
	# Efecto visual de daño
	damage_effect()
	
	# Verificar si murió
	if health <= 0:
		die()
	else:
		# Volver al estado idle después de un momento
		get_tree().create_timer(0.5).timeout.connect(func(): current_state = State.IDLE)

func damage_effect() -> void:
	"""Efecto visual al recibir daño"""
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func die() -> void:
	"""Manejar muerte del boss"""
	current_state = State.DEAD
	print("¡El boss ha sido derrotado!")
	
	boss_died.emit()
	
	# Desactivar colisiones
	if collision_shape:
		collision_shape.disabled = true
	
	# Efecto visual de muerte
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
		tween.tween_property(self, "scale", Vector2.ZERO, 1.0)

# --- Sistema de Ataque ---
func perform_attack() -> void:
	"""Ejecutar ataque"""
	print("¡Boss ataca!")
	boss_attack.emit()
	
	# Aquí podrías spawear proyectiles, crear ondas de choque, etc.
	# Por ahora, solo cambiamos el estado
	current_state = State.ATTACKING
	
	# Volver a idle después de un momento
	get_tree().create_timer(1.0).timeout.connect(func(): 
		if current_state == State.ATTACKING:
			current_state = State.IDLE
	)

# --- Señales ---
func _on_attack_timer_timeout() -> void:
	"""Timer de ataque terminó"""
	if current_state == State.IDLE and player_reference:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		if distance_to_player <= detection_range:
			perform_attack()

func _on_hurt_area_body_entered(body: Node2D) -> void:
	"""Detectar colisión con el jugador"""
	if body.has_method("take_damage") and current_state != State.DEAD:
		# El jugador tocó al boss y recibe daño
		body.take_damage(attack_damage)
