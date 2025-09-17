extends Node2D

@onready var shop: AnimatedSprite2D = $Shop
@onready var botanic_panic: AnimatedSprite2D = $BotaticPanic
@onready var clip_joint_calamity: AnimatedSprite2D = $ClipJointCalamity
@onready var home: AnimatedSprite2D = $Home
@onready var ruse_of_an_ooze: AnimatedSprite2D = $RuseOfAnOoze
@onready var shump_tutorial: AnimatedSprite2D = $ShumpTutorial

func _ready() -> void:
	start_all_animations()
	MusicPlayer.force_play_music("map_theme")

func start_all_animations() -> void:
	if shop: shop.play()
	if botanic_panic: botanic_panic.play()
	if clip_joint_calamity: clip_joint_calamity.play()
	if home: home.play()
	if ruse_of_an_ooze: ruse_of_an_ooze.play()
	if shump_tutorial: shump_tutorial.play()
