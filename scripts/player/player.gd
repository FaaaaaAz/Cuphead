# player.gd
extends CharacterBody2D

# --- Escenas Precargadas ---
const BULLET_SCENE = preload("res://scenes/player/player_bullet.tscn")

# --- Variables ---
# Propiedades exportadas para ajustar desde el Inspector
@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var health: int = 3
@export var invincibility_time: float = 1.0
@export var shoot_cooldown: float = 0.05

# Variables de dash
@export var dash_distance: float = 200.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 1.0
@export var dash_invincibility_time: float = 0.2

# Variables internas
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invincible: bool = false
var facing_right: bool = true
var is_dead: bool = false
var can_shoot: bool = true
var shoot_timer: float = 0.0

# Variables para el sistema de disparo en 8 direcciones
var is_crouching: bool = false
var shoot_direction: Vector2 = Vector2.RIGHT

# Variables para el sistema de dash
var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 0.0

# Referencias a nodos (se configurarán en Godot)
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var muzzle: Marker2D = $Muzzle

# Señales para comunicarse con otros nodos
signal player_hit
signal player_died

# --- Funciones de Inicialización ---
func _ready() -> void:
	# Asegurar que puede disparar al inicio
	can_shoot = true
	shoot_timer = 0.0
	
	# Configurar el timer de invencibilidad
	if invincibility_timer:
		invincibility_timer.wait_time = invincibility_time
		invincibility_timer.one_shot = true
		invincibility_timer.timeout.connect(_on_invincibility_timeout)
	
	# Activar procesamiento
	set_process(true)

func _process(_delta: float) -> void:
	# Debug opcional: mostrar estado de teclas cuando se dispara
	if Input.is_action_just_pressed("shoot"):
		print("=== DEBUG ESTADO DE TECLAS ===")
		print("A presionada: ", Input.is_action_pressed("move_left"))
		print("D presionada: ", Input.is_action_pressed("move_right"))
		print("W presionada: ", Input.is_action_pressed("move_up"))
		print("S presionada: ", Input.is_action_pressed("move_down"))
		print("Puede disparar: ", can_shoot)
		print("===============================")
	
	# Debug opcional: mostrar estado del dash
	if Input.is_action_just_pressed("dash"):
		print("=== DEBUG ESTADO DE DASH ===")
		print("Puede dashear: ", can_dash)
		print("Está dasheando: ", is_dashing)
		print("Cooldown restante: ", dash_cooldown_timer)
		print("===============================")

# --- Lógica Principal ---

# Usar solo _process para máxima confiabilidad
func _input(event: InputEvent) -> void:
	# Detectar disparo cuando se hace clic
	if event.is_action_pressed("shoot") and can_shoot and not is_dead:
		print("=== DISPARO DETECTADO ===")
		calculate_shoot_direction()
		shoot()
	# Detectar dash
	elif event.is_action_pressed("dash") and can_dash and not is_dead:
		print("=== DASH DETECTADO ===")
		start_dash()
	elif Input.is_action_just_pressed("ui_cancel"):
		# Volver al mapa del mundo con ESC
		print("Volviendo al mapa del mundo...")
		if SceneTransition:
			SceneTransition.circular_transition_to("res://scenes/ui/world_map.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _physics_process(delta: float) -> void:
	# No procesar física si el jugador está muerto
	if is_dead:
		return
	
	# Actualizar timer de disparo
	if not can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true
	
	# Actualizar timers de dash
	update_dash_timers(delta)
	
	# Si está dasheando, manejar el dash
	if is_dashing:
		handle_dash_movement(delta)
		return  # No procesar movimiento normal durante el dash
	
	# Detectar si está agachado (solo si no está dasheando)
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()
	
	# Actualizar el estado visual del sprite
	update_sprite_state()
	
	# 1. Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Manejar salto (no puede saltar si está agachado)
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	# 3. Manejar movimiento horizontal (más lento si está agachado)
	var direction: float = Input.get_axis("move_left", "move_right")
	var current_speed = speed
	
	# Reducir velocidad si está agachado
	if is_crouching:
		current_speed = speed * 0.5
	
	if direction:
		velocity.x = direction * current_speed
		# Cambiar dirección del sprite
		if direction > 0 and not facing_right:
			flip_sprite()
		elif direction < 0 and facing_right:
			flip_sprite()
	else:
		# Frenar suavemente
		velocity.x = move_toward(velocity.x, 0, current_speed)

	# 4. Aplicar movimiento
	move_and_slide()

# --- Funciones de Utilidad ---
func flip_sprite() -> void:
	"""Voltear el sprite horizontalmente"""
	facing_right = !facing_right
	if sprite:
		sprite.flip_h = !facing_right

func update_sprite_state() -> void:
	"""Actualizar el estado visual del sprite"""
	if not sprite:
		return
	
	# Cambiar escala Y para simular agacharse
	if is_crouching:
		sprite.scale.y = 0.7  # Más bajo cuando está agachado
	else:
		sprite.scale.y = 1.0  # Altura normal

# --- Sistema de Dash ---
func update_dash_timers(delta: float) -> void:
	"""Actualizar los timers del dash"""
	# Timer de duración del dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			end_dash()
	
	# Timer de cooldown del dash
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true
			print("Dash disponible de nuevo")

func start_dash() -> void:
	"""Iniciar el dash"""
	if not can_dash or is_dead:
		print("No puede dashear - can_dash: ", can_dash, " is_dead: ", is_dead)
		return
	
	# Determinar dirección del dash
	var input_direction = Vector2.ZERO
	
	# Detectar input direccional
	if Input.is_action_pressed("move_left"):
		input_direction.x = -1
	elif Input.is_action_pressed("move_right"):
		input_direction.x = 1
	else:
		# Si no hay input, dashear hacia donde mira
		input_direction.x = 1 if facing_right else -1
	
	# Permitir dash vertical también
	if Input.is_action_pressed("move_up"):
		input_direction.y = -1
	elif Input.is_action_pressed("move_down") and not is_on_floor():
		input_direction.y = 1
	
	# Normalizar dirección
	dash_direction = input_direction.normalized()
	
	# Calcular velocidad del dash
	dash_speed = dash_distance / dash_duration
	
	# Activar dash
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	# Activar invencibilidad temporal
	if not is_invincible:
		become_dash_invincible()
	
	# Efecto visual del inicio del dash
	create_dash_effect()
	
	print("¡DASH INICIADO! Dirección: ", dash_direction, " Velocidad: ", dash_speed)

func create_dash_effect() -> void:
	"""Crear efectos visuales del dash"""
	if sprite:
		# Efecto de scale durante el dash
		var tween = create_tween()
		tween.parallel().tween_property(sprite, "scale", Vector2(1.3, 0.8), 0.05)
		tween.parallel().tween_property(sprite, "modulate", Color(1.5, 1.5, 2.0), 0.05)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
		tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)

func handle_dash_movement(delta: float) -> void:
	"""Manejar el movimiento durante el dash"""
	# Mover en la dirección del dash
	velocity = dash_direction * dash_speed
	
	# Aplicar el movimiento
	move_and_slide()

func end_dash() -> void:
	"""Terminar el dash"""
	is_dashing = false
	dash_timer = 0.0
	
	# Reducir la velocidad gradualmente al terminar el dash
	velocity = velocity * 0.2
	
	# Efecto visual del final del dash
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.05)
		tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	print("Dash terminado")

func become_dash_invincible() -> void:
	"""Activar invencibilidad temporal durante el dash"""
	is_invincible = true
	
	# Efecto visual de dash (más sutil que el daño)
	if sprite:
		var tween = create_tween()
		tween.set_loops(int(dash_invincibility_time * 15))  # Parpadeo más rápido
		tween.tween_property(sprite, "modulate:a", 0.6, 0.03)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.03)
	
	# Timer de invencibilidad de dash
	get_tree().create_timer(dash_invincibility_time).timeout.connect(func():
		if is_invincible and not invincibility_timer.time_left > 0:
			is_invincible = false
			if sprite:
				sprite.modulate.a = 1.0
			print("Invencibilidad de dash terminada")
	)

func take_damage(damage: int = 1) -> void:
	"""Recibir daño si no es invencible o muerto"""
	if is_invincible or is_dead:
		return
	
	health -= damage
	print("Jugador recibió daño. Vida restante: ", health)
	
	# Emitir señal de daño
	player_hit.emit()
	
	# Activar invencibilidad temporal
	become_invincible()
	
	# Verificar si el jugador murió
	if health <= 0:
		die()

func become_invincible() -> void:
	"""Activar invencibilidad temporal"""
	is_invincible = true
	
	# Efecto visual de parpadeo
	if sprite:
		var tween = create_tween()
		tween.set_loops(int(invincibility_time * 10))
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	
	# Iniciar timer
	if invincibility_timer:
		invincibility_timer.start()

func _on_invincibility_timeout() -> void:
	"""Terminar invencibilidad"""
	is_invincible = false
	if sprite:
		sprite.modulate.a = 1.0

func die() -> void:
	"""Manejar muerte del jugador"""
	if is_dead:
		return  # Evitar múltiples llamadas
	
	is_dead = true
	print("¡El jugador ha muerto!")
	player_died.emit()
	
	# Ocultar el sprite del jugador
	hide()
	
	# Desactivar la colisión de forma segura
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Opcional: Reiniciar después de unos segundos
	# get_tree().create_timer(3.0).timeout.connect(respawn)

func heal(amount: int = 1) -> void:
	"""Curar al jugador"""
	health += amount
	print("Jugador curado. Vida actual: ", health)

func respawn() -> void:
	"""Función para revivir al jugador (opcional)"""
	if not is_dead:
		return
	
	print("¡El jugador ha revivido!")
	
	# Restaurar estado
	is_dead = false
	health = 3
	is_invincible = false
	
	# Mostrar el sprite
	show()
	
	# Reactivar la colisión
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	
	# Restaurar color normal
	if sprite:
		sprite.modulate = Color.WHITE

func shoot() -> void:
	if not can_shoot or is_dead:
		print("No puede disparar - can_shoot: ", can_shoot, " is_dead: ", is_dead)
		return
	
	can_shoot = false
	shoot_timer = shoot_cooldown
	
	var bullet_instance = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	
	# Usar el nuevo sistema de dirección vectorial
	bullet_instance.set_direction_vector(shoot_direction)
	
	print("¡BALA DISPARADA! Posición: ", muzzle.global_position, " Dirección: ", shoot_direction)

func calculate_shoot_direction() -> void:
	"""Calcular la dirección de disparo basada en el input del jugador"""
	# Usar is_action_pressed en lugar de get_axis para mejor detección de combinaciones
	var left_pressed = Input.is_action_pressed("move_left")
	var right_pressed = Input.is_action_pressed("move_right") 
	var up_pressed = Input.is_action_pressed("move_up")
	var down_pressed = Input.is_action_pressed("move_down")
	
	# Vector de dirección
	var direction = Vector2.ZERO
	
	# Determinar dirección horizontal
	if left_pressed and not right_pressed:
		direction.x = -1
	elif right_pressed and not left_pressed:
		direction.x = 1
	elif left_pressed and right_pressed:
		# Si ambas están presionadas, usar la dirección que está mirando
		direction.x = 1 if facing_right else -1
	else:
		# Si no hay input horizontal, usar la dirección que está mirando
		direction.x = 1 if facing_right else -1
	
	# Determinar dirección vertical
	if up_pressed and not down_pressed:
		direction.y = -1  # Hacia arriba (en Godot Y negativo es arriba)
	elif down_pressed and not up_pressed:
		direction.y = 1   # Hacia abajo
	elif is_crouching:
		# Si está agachado pero no hay input vertical, disparar en diagonal hacia abajo
		direction.y = 0.5
	else:
		# Sin input vertical, disparar recto
		direction.y = 0
	
	# Si no hay dirección (caso muy raro), usar dirección por defecto
	if direction == Vector2.ZERO:
		direction.x = 1 if facing_right else -1
	
	# Normalizar y asignar
	shoot_direction = direction.normalized()
	
	# Debug mejorado
	print("Input detallado - Left: ", left_pressed, " Right: ", right_pressed, " Up: ", up_pressed, " Down: ", down_pressed)
	print("Crouching: ", is_crouching, " OnFloor: ", is_on_floor(), " FacingRight: ", facing_right)
	print("Dirección calculada: ", shoot_direction)
