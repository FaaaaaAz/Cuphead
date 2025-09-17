extends Control

@export var auto_advance_time: float = 3.0
@export var enable_auto_advance: bool = false
@export var story_folder: String = "res://assets/art/pages_history/"
@export var next_scene_after_story: String = "res://scenes/ui/main_menu.tscn"

@onready var story_image: TextureRect = $StoryImage
@onready var progress_bar: ProgressBar = $UI/ProgressBar
@onready var instructions: Label = $UI/Instructions
@onready var timer: Timer = $Timer

var story_frames: Array[String] = []
var current_frame: int = 0
var total_frames: int = 0

func _ready():
	load_story_frames()
	setup_ui()
	show_current_frame()
	
	if enable_auto_advance:
		timer.wait_time = auto_advance_time
		timer.start()

func load_story_frames():
	var dir = DirAccess.open(story_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") and not file_name.ends_with(".import"):
				story_frames.append(story_folder + file_name)
			file_name = dir.get_next()
		
		story_frames.sort_custom(sort_frames_numerically)
		total_frames = story_frames.size()

func sort_frames_numerically(a: String, b: String) -> bool:
	var a_name = a.get_file().get_basename()
	var b_name = b.get_file().get_basename()
	
	var regex = RegEx.new()
	regex.compile(r"(\d+)$")
	
	var a_result = regex.search(a_name)
	var b_result = regex.search(b_name)
	
	if a_result and b_result:
		var a_num = a_result.get_string().to_int()
		var b_num = b_result.get_string().to_int()
		return a_num < b_num
	else:
		var a_has_turn = "turn" in a_name
		var b_has_turn = "turn" in b_name
		var a_is_base = not a_has_turn and not "intro" in a_name and not "outro" in a_name
		var b_is_base = not b_has_turn and not "intro" in b_name and not "outro" in b_name
		
		if a_is_base and b_has_turn:
			return true
		elif a_has_turn and b_is_base:
			return false
		else:
			return a_name < b_name

func setup_ui():
	if total_frames > 0:
		progress_bar.max_value = total_frames
		progress_bar.value = 1
		
		if enable_auto_advance:
			if total_frames > 50:
				instructions.text = "Introducción animada | Click para acelerar | ESC para saltar"
			else:
				instructions.text = "Historia automática | Click para avanzar | ESC para saltar"
		else:
			instructions.text = "Click para continuar | ESC para saltar historia"
		pass
	else:
		instructions.text = "Error: No se encontraron imágenes de historia"

func show_current_frame():
	if current_frame < total_frames and current_frame >= 0:
		var texture_path = story_frames[current_frame]
		var texture = load(texture_path)
		
		if texture:
			story_image.texture = texture
			progress_bar.value = current_frame + 1
		else:
			pass
	else:
		end_story()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		end_story()
		return
	
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		if enable_auto_advance:
			var new_time = max(0.05, auto_advance_time * 0.5)
			timer.wait_time = new_time
		else:
			advance_frame()

func advance_frame():
	current_frame += 1
	
	if current_frame < total_frames:
		show_current_frame()
		
		if enable_auto_advance and timer:
			timer.start()
	else:
		end_story()

func _on_timer_timeout():
	if enable_auto_advance:
		advance_frame()

func end_story():
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(next_scene_after_story)

func set_auto_advance(enabled: bool, time: float = 3.0):
	enable_auto_advance = enabled
	auto_advance_time = time
	if timer:
		timer.wait_time = time

func set_next_scene(scene_path: String):
	next_scene_after_story = scene_path

func set_story_folder(folder_path: String):
	story_folder = folder_path
