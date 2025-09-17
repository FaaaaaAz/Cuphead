extends Area2D

var speed: float = 800.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta
	
	if position.x > 2000 or position.x < -500 or position.y > 1000 or position.y < -500:
		queue_free()

func set_direction_vector(new_direction: Vector2) -> void:
	direction = new_direction.normalized()

func set_direction(new_direction: int) -> void:
	if new_direction > 0:
		direction = Vector2.RIGHT
	else:
		direction = Vector2.LEFT

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("boss"):
		body.take_damage(1)
	
	queue_free()

func _on_body_exited(_body: Node2D) -> void:
	pass
