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

# Variables internas
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invincible: bool = false
var facing_right: bool = true
var is_dead: bool = false
var can_shoot: bool = true
var shoot_timer: float = 0.0

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

# --- Lógica Principal ---

# Usar solo _process para máxima confiabilidad
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and can_shoot and not is_dead:
		shoot()

func _physics_process(delta: float) -> void:
	# No procesar física si el jugador está muerto
	if is_dead:
		return
	
	# Actualizar timer de disparo
	if not can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true
	
	# 1. Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Manejar salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Manejar disparo también aquí como respaldo
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

	# 4. Manejar movimiento horizontal
	var direction: float = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * speed
		# Cambiar dirección del sprite
		if direction > 0 and not facing_right:
			flip_sprite()
		elif direction < 0 and facing_right:
			flip_sprite()
	else:
		# Frenar suavemente
		velocity.x = move_toward(velocity.x, 0, speed)

	# 5. Aplicar movimiento
	move_and_slide()

# --- Funciones de Utilidad ---
func flip_sprite() -> void:
	"""Voltear el sprite horizontalmente"""
	facing_right = !facing_right
	if sprite:
		sprite.flip_h = !facing_right

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
		return
	
	can_shoot = false
	shoot_timer = shoot_cooldown
	
	var bullet_instance = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	
	if not facing_right:
		bullet_instance.set_direction(-1)
	else:
		bullet_instance.set_direction(1)
	
	print("Jugador disparo")
