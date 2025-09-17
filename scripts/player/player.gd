extends CharacterBody2D

const BULLET_SCENE = preload("res://scenes/player/player_bullet.tscn")

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var health: int = 3
@export var invincibility_time: float = 1.0
@export var shoot_cooldown: float = 0.05

@export var dash_distance: float = 200.0
@export var dash_duration: float = 0.25
@export var dash_cooldown: float = 1.0
@export var dash_invincibility_time: float = 0.2

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_invincible: bool = false
var facing_right: bool = true
var is_dead: bool = false
var can_shoot: bool = true
var shoot_timer: float = 0.0

var is_crouching: bool = false
var shoot_direction: Vector2 = Vector2.RIGHT
var is_shooting: bool = false
var shoot_animation_timer: float = 0.0
var shoot_animation_duration: float = 0.2

var is_dashing: bool = false
var can_dash: bool = true
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var dash_speed: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var muzzle: Marker2D = $Muzzle

signal player_hit
signal player_died

func _ready() -> void:
	can_shoot = true
	shoot_timer = 0.0
	
	if invincibility_timer:
		invincibility_timer.wait_time = invincibility_time
		invincibility_timer.one_shot = true
		invincibility_timer.timeout.connect(_on_invincibility_timeout)
	
	set_process(true)

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and can_shoot and not is_dead:
		calculate_shoot_direction()
		shoot()
	elif event.is_action_pressed("dash") and can_dash and not is_dead:
		start_dash()
	elif Input.is_action_just_pressed("ui_cancel"):
		if SceneTransition:
			SceneTransition.circular_transition_to("res://scenes/ui/world_map.tscn")
		else:
			get_tree().change_scene_to_file("res://scenes/ui/world_map.tscn")

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not can_shoot:
		shoot_timer -= delta
		if shoot_timer <= 0:
			can_shoot = true
	
	if is_shooting:
		shoot_animation_timer -= delta
		if shoot_animation_timer <= 0:
			is_shooting = false
	
	update_dash_timers(delta)
	
	if is_dashing:
		handle_dash_movement(delta)
		return
	
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()
	
	update_sprite_state()
	update_animations()
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
		velocity.y = jump_velocity

	var direction: float = Input.get_axis("move_left", "move_right")
	var current_speed = speed
	
	if is_crouching:
		current_speed = speed * 0.5
	
	if direction:
		velocity.x = direction * current_speed
		if direction > 0 and not facing_right:
			flip_sprite()
		elif direction < 0 and facing_right:
			flip_sprite()
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

func flip_sprite() -> void:
	facing_right = !facing_right
	if sprite:
		sprite.flip_h = !facing_right

func update_sprite_state() -> void:
	if not sprite:
		return
	
	if is_dashing:
		return
	
	sprite.scale.y = 1.0

func update_animations() -> void:
	if not sprite:
		return
	
	var new_animation = ""
	var is_running = abs(velocity.x) > 0 and is_on_floor()
	
	if is_shooting and is_crouching:
		new_animation = "agachau_shot"
	elif is_shooting and is_running:
		new_animation = get_run_shoot_animation_name()
	elif is_shooting:
		new_animation = get_shoot_animation_name()
	elif is_dashing:
		new_animation = "dash"
	elif is_crouching:
		new_animation = "agachau_idle"
	elif is_running:
		new_animation = "run"
	elif not is_on_floor():
		if velocity.y < 0:
			new_animation = "jump"
		else:
			new_animation = "fall"
	else:
		new_animation = "idle"
	
	if sprite.animation != new_animation:
		sprite.play(new_animation)

func update_dash_timers(delta: float) -> void:
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			end_dash()
	
	if not can_dash:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true

func start_dash() -> void:
	if not can_dash or is_dead:
		return
	
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		input_direction.x = -1
	elif Input.is_action_pressed("move_right"):
		input_direction.x = 1
	else:
		input_direction.x = 1 if facing_right else -1
	
	if Input.is_action_pressed("move_up"):
		input_direction.y = -1
	elif Input.is_action_pressed("move_down") and not is_on_floor():
		input_direction.y = 1
	
	dash_direction = input_direction.normalized()
	dash_speed = dash_distance / dash_duration
	
	is_dashing = true
	can_dash = false
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	if not is_invincible:
		become_dash_invincible()
	
	create_dash_effect()

func create_dash_effect() -> void:
	if sprite:
		var tween = create_tween()
		tween.parallel().tween_property(sprite, "modulate", Color(1.5, 1.5, 2.0), 0.05)
		tween.parallel().tween_property(sprite, "modulate", Color.WHITE, 0.1)

func handle_dash_movement(_delta: float) -> void:
	velocity = dash_direction * dash_speed
	move_and_slide()

func end_dash() -> void:
	is_dashing = false
	dash_timer = 0.0
	velocity = velocity * 0.2
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", Color(0.8, 0.8, 1.2), 0.05)
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func become_dash_invincible() -> void:
	is_invincible = true
	await get_tree().create_timer(dash_invincibility_time).timeout
	is_invincible = false

func take_damage(damage: int = 1) -> void:
	if is_invincible or is_dead:
		return
	
	health -= damage
	player_hit.emit()
	
	if health <= 0:
		die()
	else:
		become_invincible()

func become_invincible() -> void:
	if is_invincible:
		return
	
	is_invincible = true
	
	if sprite:
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(sprite, "modulate:a", 0.3, 0.1)
		tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
		
		await get_tree().create_timer(invincibility_time).timeout
		tween.kill()
		sprite.modulate.a = 1.0
	
	is_invincible = false

func _on_invincibility_timeout() -> void:
	is_invincible = false

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	health = 0
	player_died.emit()
	velocity = Vector2.ZERO
	
	if sprite:
		if sprite.sprite_frames.has_animation("death"):
			sprite.play("death")
		else:
			sprite.modulate = Color(1, 0.5, 0.5, 0.5)
	
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func heal(amount: int = 1) -> void:
	health += amount

func respawn() -> void:
	if not is_dead:
		return
	
	is_dead = false
	health = 3
	is_invincible = false
	
	show()
	
	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	
	if sprite:
		sprite.modulate = Color.WHITE

func shoot() -> void:
	if not can_shoot or is_dead:
		return
	
	can_shoot = false
	shoot_timer = shoot_cooldown
	is_shooting = true
	shoot_animation_timer = shoot_animation_duration
	
	var bullet_instance = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.set_direction_vector(shoot_direction)

func get_shoot_animation_name() -> String:
	var angle = shoot_direction.angle()
	var angle_degrees = rad_to_deg(angle)
	
	if angle_degrees < 0:
		angle_degrees += 360
	
	var animation_name = ""
	
	if angle_degrees >= 337.5 or angle_degrees < 22.5:
		animation_name = "aim_straight"
	elif angle_degrees >= 22.5 and angle_degrees < 67.5:
		animation_name = "aim_diagonal_down"
	elif angle_degrees >= 67.5 and angle_degrees < 112.5:
		animation_name = "aim_down"
	elif angle_degrees >= 112.5 and angle_degrees < 157.5:
		animation_name = "aim_diagonal_down"
	elif angle_degrees >= 157.5 and angle_degrees < 202.5:
		animation_name = "aim_straight"
	elif angle_degrees >= 202.5 and angle_degrees < 247.5:
		animation_name = "aim_diagonal_up"
	elif angle_degrees >= 247.5 and angle_degrees < 292.5:
		animation_name = "aim_up"
	elif angle_degrees >= 292.5 and angle_degrees < 337.5:
		animation_name = "aim_diagonal_up"
	else:
		animation_name = "aim_straight"
	
	return animation_name

func get_run_shoot_animation_name() -> String:
	var angle = shoot_direction.angle()
	var angle_degrees = rad_to_deg(angle)
	
	if angle_degrees < 0:
		angle_degrees += 360
	
	if angle_degrees >= 225 and angle_degrees < 315:
		return "run_shooting_diagonal_up"
	elif angle_degrees >= 45 and angle_degrees < 135:
		return "run_shooting_diagonal_down"
	else:
		return "run_shooting_straight"

func calculate_shoot_direction() -> void:
	var left_pressed = Input.is_action_pressed("move_left")
	var right_pressed = Input.is_action_pressed("move_right") 
	var up_pressed = Input.is_action_pressed("move_up")
	var down_pressed = Input.is_action_pressed("move_down")
	
	var direction = Vector2.ZERO
	
	if left_pressed and not right_pressed:
		direction.x = -1
	elif right_pressed and not left_pressed:
		direction.x = 1
	elif left_pressed and right_pressed:
		direction.x = 1 if facing_right else -1
	else:
		if up_pressed and not down_pressed:
			direction.x = 0
		elif down_pressed and not up_pressed:
			direction.x = 0
		else:
			direction.x = 1 if facing_right else -1
	
	if up_pressed and not down_pressed:
		direction.y = -1
	elif down_pressed and not up_pressed:
		direction.y = 1
	elif is_crouching:
		direction.y = 0
	else:
		direction.y = 0
	
	if direction == Vector2.ZERO:
		direction.x = 1 if facing_right else -1
	
	shoot_direction = direction.normalized()
