extends CharacterBody2D

enum State {
	INTRO,
	IDLE,
	ATTACKING,
	HURT,
	DEAD
}

@export var health: int = 100
@export var max_health: int = 100
@export var attack_damage: int = 1
@export var detection_range: float = 1000.0
@export var attack_cooldown: float = 3.0

var current_state: State = State.INTRO
var player_reference: CharacterBody2D = null
var attack_timer: float = 0.0
var facing_right: bool = false
var intro_finished: bool = false
var attack_pattern_index: int = 0
var attack_patterns: Array[String] = ["face_attack", "firing_seeds"]

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_timer_node: Timer = $AttackTimer
@onready var hurt_area: Area2D = $HurtArea

signal boss_died
signal boss_attack

func _ready() -> void:
	health = max_health
	add_to_group("boss")
	
	if attack_timer_node:
		attack_timer_node.wait_time = attack_cooldown
		attack_timer_node.timeout.connect(_on_attack_timer_timeout)
		attack_timer_node.stop()
	
	if hurt_area:
		hurt_area.body_entered.connect(_on_hurt_area_body_entered)
	
	find_player()
	
	if player_reference:
		look_at_player()
	
	start_intro_sequence()

func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_reference = players[0]

func start_intro_sequence() -> void:
	current_state = State.INTRO
	if animated_sprite:
		disconnect_animation_signals()
		animated_sprite.play("intro")
		animated_sprite.animation_finished.connect(_on_intro_finished)

func _on_intro_finished() -> void:
	if current_state == State.INTRO:
		intro_finished = true
		current_state = State.IDLE
		if attack_timer_node:
			attack_timer_node.start()

func disconnect_animation_signals() -> void:
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_intro_finished):
		animated_sprite.animation_finished.disconnect(_on_intro_finished)
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_attack_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_attack_animation_finished)
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_death_animation_finished):
		animated_sprite.animation_finished.disconnect(_on_death_animation_finished)

func _physics_process(_delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	update_animation()
	
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
	pass

func idle_behavior() -> void:
	if player_reference:
		look_at_player()

func update_animation() -> void:
	if not animated_sprite:
		return
		
	match current_state:
		State.INTRO:
			if animated_sprite.animation != "intro":
				animated_sprite.play("intro")
		State.IDLE:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		State.ATTACKING:
			pass
		State.HURT:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		State.DEAD:
			if animated_sprite.animation != "death":
				animated_sprite.play("death")

func attack_behavior() -> void:
	if player_reference:
		look_at_player()

func hurt_behavior() -> void:
	pass

func look_at_player() -> void:
	if not player_reference:
		return
	
	var player_x = player_reference.global_position.x
	var boss_x = global_position.x
	var should_face_right = player_x > boss_x
	
	if should_face_right != facing_right:
		facing_right = should_face_right
		if animated_sprite:
			animated_sprite.flip_h = !facing_right

func take_damage(damage: int) -> void:
	if current_state == State.DEAD:
		return
	
	health -= damage
	damage_effect()
	
	if health <= 0:
		die()
		return
	
	if current_state != State.ATTACKING:
		current_state = State.HURT
		get_tree().create_timer(0.5).timeout.connect(func(): 
			if current_state == State.HURT:
				current_state = State.IDLE
		)

func damage_effect() -> void:
	if animated_sprite:
		var tween = create_tween()
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.1)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)

func die() -> void:
	current_state = State.DEAD
	KnockoutDisplay.show_knockout()
	boss_died.emit()
	
	if collision_shape:
		collision_shape.disabled = true
	
	if animated_sprite:
		disconnect_animation_signals()
		animated_sprite.play("death")
	
	await get_tree().create_timer(4.0).timeout
	SceneTransition.change_scene("res://scenes/ui/world_map.tscn")
	
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_death_animation_finished)

func _on_death_animation_finished() -> void:
	if current_state == State.DEAD:
		if animated_sprite:
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate:a", 0.0, 1.0)
			tween.tween_property(self, "scale", Vector2.ZERO, 1.0)

func perform_attack() -> void:
	if not intro_finished:
		return
		
	boss_attack.emit()
	look_at_player()
	current_state = State.ATTACKING
	
	var attack_animation = attack_patterns[attack_pattern_index]
	attack_pattern_index = (attack_pattern_index + 1) % attack_patterns.size()
	
	if animated_sprite:
		disconnect_animation_signals()
		animated_sprite.play(attack_animation)
		animated_sprite.animation_finished.connect(_on_attack_animation_finished)

func _on_attack_animation_finished() -> void:
	if current_state == State.ATTACKING:
		current_state = State.IDLE

func _on_attack_timer_timeout() -> void:
	if current_state == State.IDLE and player_reference and intro_finished:
		var distance_to_player = global_position.distance_to(player_reference.global_position)
		if distance_to_player <= detection_range:
			perform_attack()

func _on_hurt_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and current_state != State.DEAD:
		body.take_damage(attack_damage)
