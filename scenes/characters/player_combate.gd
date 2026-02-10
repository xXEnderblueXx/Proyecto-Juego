extends CharacterBody2D

# Referencias al sistema de animación
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var menu = $Camera2D/CanvasLayer/menu

func _ready() -> void:
	menu.process_mode = Node.PROCESS_MODE_DISABLED
	menu.visible = false
	# 1. Encendemos el árbol de animación
	anim_tree.active = true
	
	# 2. Forzamos el inicio en el estado de reposo de combate
	# Asegúrate de que el nodo en tu AnimationTree se llame exactamente así
	state_machine.travel("idle_combate")
	
	print("SISTEMA DE RITMO: Player listo para el baile de los Diablos.")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu_en_partida"):
		toggle_menu()
	# En esta escena el personaje no se mueve, solo baila.
	# Por eso no usamos move_and_slide() ni calculamos velocity.
	manejar_ritmo_baile()	

func manejar_ritmo_baile() -> void:
	# Escuchamos los inputs y viajamos a los nodos que configuraste en tu 'Estrella'
	if Input.is_action_just_pressed("ui_up"):
		state_machine.travel("jump")
	
	elif Input.is_action_just_pressed("ui_down"):
		state_machine.travel("crouch")
	
	elif Input.is_action_just_pressed("ui_left"):
		state_machine.travel("left")
		
	elif Input.is_action_just_pressed("ui_right"):
		state_machine.travel("right")

# NOTA DE INGENIERÍA:
# La vuelta al 'idle_combate' ocurre sola gracias a que configuraste 
# las transiciones en modo 'At End' y 'Auto'.
func toggle_menu() -> void:
# Aplicamos la lógica de inversión booleana para el menú
	menu.visible = !menu.visible
	menu.process_mode = Node.PROCESS_MODE_INHERIT if menu.visible else Node.PROCESS_MODE_DISABLED
