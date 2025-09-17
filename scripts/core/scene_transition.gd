extends CanvasLayer

@onready var transition_sprite = $TransitionSprite

var next_scene_path = ""
var is_transitioning = false

func _ready():
	transition_sprite.animation_finished.connect(_on_animation_finished)
	transition_sprite.hide()

func change_scene(scene_path):
	if is_transitioning:
		return
	
	is_transitioning = true
	transition_sprite.show()
	next_scene_path = scene_path
	transition_sprite.play("close")

func _on_animation_finished():
	var anim_name = transition_sprite.animation
	
	if anim_name == "close":
		get_tree().change_scene_to_file(next_scene_path)
		transition_sprite.play("open")
	elif anim_name == "open":
		transition_sprite.hide()
		is_transitioning = false

func reset_transition():
	is_transitioning = false
	transition_sprite.hide()

func circular_transition_to(scene_path):
	change_scene(scene_path)
