# boss.gd
extends CharacterBody2D

# --- Estados del Boss ---
enum State {
	INTRO,     # Animación de introducción
	IDLE,      # Esperando
	ATTACKING, # Atacando
	HURT,      # Recibiendo daño
	DEAD       # Derrotado
}

# --- Variables Exportadas ---
@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 1
@export var detection_range: float = 1000.0
@export var attack_cooldown: float = 3.0

# --- Variables Internas ---
var current_state: State = State.INTRO
var player_reference: CharacterBody2D = null
var attack_timer: float = 0.0
var facing_right: bool = false  # Iniciar mirando hacia la izquierda
var intro_finished: bool = false
var attack_pattern_index: int = 0  # Para alternar entre face_attack y firing_seeds
var attack_patterns: Array[String] = ["face_attack", "firing_seeds"]
var is_in_final_phase: bool = false  # Cambiar a true cuando la vida sea ≤ 30%

# Referencias a nodos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
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
	
	print("Configurando boss - attack_cooldown: ", attack_cooldown)
	
	# Configurar timer de ataque
	if attack_timer_node:
		attack_timer_node.wait_time = attack_cooldown
		attack_timer_node.timeout.connect(_on_attack_timer_timeout)
		attack_timer_node.stop()  # No iniciar hasta después del intro
		print("Timer configurado correctamente")
	else:
		print("ERROR: No se encontró AttackTimer!")
	
	# Configurar área de daño
	if hurt_area:
		hurt_area.body_entered.connect(_on_hurt_area_body_entered)
	
	# Buscar al jugador en la escena
	find_player()
	
	# Orientar hacia el jugador desde el inicio
	if player_reference:
		look_at_player()
	
	# Iniciar con animación de intro
	start_intro_sequence()

func find_player() -> void:
	"""Buscar al jugador en la escena"""
	var players = get_tree().get_nodes_in_group("player")
	print("Buscando jugador - encontrados: ", players.size())
	if players.size() > 0:
		player_reference = players[0]
		print("Jugador encontrado: ", player_reference.name)
	else:
		print("ERROR: No se encontró ningún jugador en el grupo 'player'")

func start_intro_sequence() -> void:
	"""Iniciar la secuencia de introducción"""
	current_state = State.INTRO
	if animated_sprite:
		disconnect_animation_signals()  # Limpiar conexiones previas
		animated_sprite.play("intro")
		# Conectar señal para cuando termine la animación intro
		animated_sprite.animation_finished.connect(_on_intro_finished)

func _on_intro_finished() -> void:
	"""Llamado cuando la animación intro termina"""
	print("_on_intro_finished llamado - Estado actual: ", current_state)
	if current_state == State.INTRO:
		print("Intro terminado, cambiando a idle")
		intro_finished = true
		current_state = State.IDLE
		# Iniciar el timer de ataques
		if attack_timer_node:
			print("Iniciando timer de ataques con wait_time: ", attack_timer_node.wait_time)
			attack_timer_node.start()
		else:
			print("ERROR: attack_timer_node no encontrado!")

func disconnect_animation_signals() -> void:
	"""Desconectar todas las señales de animación para evitar problemas"""
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_intro_finished):
		animated_sprite.animation_finished.disconnect(_on_intro_finished)
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_attack_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_attack_animation_finished)
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_death_animation_finished)

# --- Lógica Principal ---
func _physics_process(_delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	# Actualizar animaciones
	update_animation()
	
	# Actualizar comportamiento según el estado
	match current_state:
		State.INTRO:
			intro_behavior()
		State.IDLE:
			idle_behavior()
		State.ATTACKING:
			attack_behavior()
		State.HURT:
			hurt_behavior()

func intro_behavior() -> void:
	"""Comportamiento durante la introducción"""
	# Durante el intro, el boss no hace nada especial, solo reproduce la animación
	pass

func idle_behavior() -> void:
	"""Comportamiento en estado idle"""
	if player_reference:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		
		# Siempre mirar hacia el jugador durante idle
		look_at_player()
		
		# Si el jugador está cerca, prepararse para atacar
		if distance_to_player <= detection_range:
			# El ataque se manejará con el timer
			pass

func update_animation() -> void:
	"""Actualizar animación según el estado actual"""
	if not animated_sprite:
		return
		
	match current_state:
		State.INTRO:
			if animated_sprite.animation != "intro":
				animated_sprite.play("intro")
		State.IDLE:
			# Verificar si está en fase final (30% de vida o menos)
			if is_in_final_phase and animated_sprite.animation != "final_idle":
				animated_sprite.play("final_idle")
			elif not is_in_final_phase and animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		State.ATTACKING:
			# No cambiar animación aquí - se maneja en perform_attack()
			pass
		State.HURT:
			# En la fase final, mantener final_idle incluso al recibir daño
			if is_in_final_phase and animated_sprite.animation != "final_idle":
				animated_sprite.play("final_idle")
			elif not is_in_final_phase and animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		State.DEAD:
			if animated_sprite.animation != "death":
				animated_sprite.play("death")

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
	
	var player_x = player_reference.global_position.x
	var boss_x = global_position.x
	var should_face_right = player_x > boss_x
	
	if should_face_right != facing_right:
		facing_right = should_face_right
		if animated_sprite:
			animated_sprite.flip_h = !facing_right
			print("Boss volteado hacia el jugador - facing_right: ", facing_right, " | flip_h: ", animated_sprite.flip_h)

# --- Sistema de Daño ---
func take_damage(damage: int) -> void:
	"""Recibir daño"""
	if current_state == State.DEAD:
		return
	
	health -= damage
	
	# Verificar si entró en la fase final (30% de vida o menos)
	var health_percentage = float(health) / float(max_health) * 100.0
	if health_percentage <= 30.0 and not is_in_final_phase:
		is_in_final_phase = true
		print("¡Boss entró en fase final! Vida: ", health, "/", max_health, " (", health_percentage, "%)")
	
	print("Boss recibió ", damage, " de daño. Vida restante: ", health, " | Estado actual: ", current_state)
	
	# Efecto visual de daño (siempre)
	damage_effect()
	
	# Verificar si murió
	if health <= 0:
		die()
		return
	
	# Solo cambiar a HURT si NO está atacando
	if current_state != State.ATTACKING:
		current_state = State.HURT
		# Volver al estado idle después de un momento
		get_tree().create_timer(0.5).timeout.connect(func(): 
			if current_state == State.HURT:  # Solo si sigue en HURT
				current_state = State.IDLE
		)
	else:
		print("Boss recibió daño durante ataque - no interrumpiendo animación")

func damage_effect() -> void:
	"""Efecto visual al recibir daño"""
	if animated_sprite:
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func die() -> void:
	"""Manejar muerte del boss"""
	current_state = State.DEAD
	print("¡El boss ha sido derrotado!")
	
	boss_died.emit()
	
	# Desactivar colisiones
	if collision_shape:
		collision_shape.disabled = true
	
	# Reproducir animación de muerte
	if animated_sprite:
		disconnect_animation_signals()  # Limpiar conexiones previas
		animated_sprite.play("death")
		# Conectar para efectos adicionales cuando termine la animación de muerte
		animated_sprite.animation_finished.connect(_on_death_animation_finished)

func _on_death_animation_finished() -> void:
	"""Llamado cuando termina la animación de muerte"""
	if current_state == State.DEAD:
		print("Animación de muerte terminada, aplicando efectos finales")
		# Efectos adicionales después de la animación de muerte
		if animated_sprite:
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate:a", 0.0, 1.0)
			tween.tween_property(self, "scale", Vector2.ZERO, 1.0)

# --- Sistema de Ataque ---
func perform_attack() -> void:
	"""Ejecutar ataque con alternancia entre face_attack y firing_seeds"""
	if not intro_finished:
		return
		
	print("¡Boss ataca!")
	boss_attack.emit()
	
	# IMPORTANTE: Mirar hacia el jugador ANTES de atacar
	look_at_player()
	
	# Cambiar al estado de ataque
	current_state = State.ATTACKING
	
	# Seleccionar el patrón de ataque alternado
	var attack_animation = attack_patterns[attack_pattern_index]
	attack_pattern_index = (attack_pattern_index + 1) % attack_patterns.size()
	
	print("Ejecutando ataque: ", attack_animation)
	
	# Reproducir la animación de ataque
	if animated_sprite:
		disconnect_animation_signals()  # Limpiar conexiones previas
		animated_sprite.play(attack_animation)
		# Conectar señal para volver a idle cuando termine la animación
		animated_sprite.animation_finished.connect(_on_attack_animation_finished)

func _on_attack_animation_finished() -> void:
	"""Llamado cuando termina una animación de ataque"""
	print("Animación de ataque terminada - Estado actual: ", current_state)
	if current_state == State.ATTACKING:
		current_state = State.IDLE
		print("Ataque terminado correctamente, volviendo a idle")
	else:
		print("Ataque terminado pero el estado ya había cambiado a: ", current_state)

# --- Señales ---
func _on_attack_timer_timeout() -> void:
	"""Timer de ataque terminó"""
	print("Timer de ataque terminó - Estado actual: ", current_state)
	if current_state == State.IDLE and player_reference and intro_finished:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		print("Distancia al jugador: ", distance_to_player, " - Rango: ", detection_range)
		if distance_to_player <= detection_range:
			perform_attack()
		else:
			print("Jugador muy lejos para atacar")
	elif current_state == State.HURT:
		print("Boss está en estado HURT, esperando para atacar")
	elif current_state == State.ATTACKING:
		print("Boss ya está atacando, ignorando timer")

func _on_hurt_area_body_entered(body: Node2D) -> void:
	"""Detectar colisión con el jugador"""
	if body.has_method("take_damage") and current_state != State.DEAD:
		# El jugador tocó al boss y recibe daño
		body.take_damage(attack_damage)
