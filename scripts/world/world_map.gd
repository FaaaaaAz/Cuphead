# world_map.gd
extends Node2D

# Referencias a todos los elementos animados del mapa
@onready var shop: AnimatedSprite2D = $Shop
@onready var botanic_panic: AnimatedSprite2D = $BotaticPanic
@onready var clip_joint_calamity: AnimatedSprite2D = $ClipJointCalamity
@onready var home: AnimatedSprite2D = $Home
@onready var ruse_of_an_ooze: AnimatedSprite2D = $RuseOfAnOoze
@onready var shump_tutorial: AnimatedSprite2D = $ShumpTutorial

# Esta función se ejecuta cuando la escena está lista
func _ready() -> void:
	# Iniciar todas las animaciones automáticamente
	start_all_animations()

func start_all_animations() -> void:

	# Shop
	if shop:
		shop.play()
	
	# Botanic Panic
	if botanic_panic:
		botanic_panic.play()
	
	# Clip Joint Calamity
	if clip_joint_calamity:
		clip_joint_calamity.play()
	
	# Home
	if home:
		home.play()
	
	# Ruse of an Ooze
	if ruse_of_an_ooze:
		ruse_of_an_ooze.play()
	
	# Shmup Tutorial
	if shump_tutorial:
		shump_tutorial.play()
	
