extends PlayerCharacter

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var camera = $Camera2D 
@onready var menu: Control = $Camera2D/CanvasLayer/menu
@export_group("Skins del Personaje")
@export var sheet_normal: Texture2D    # Aquí irá tu traje de Diablo base
@export var sheet_especial: Texture2D  # El traje que consigues con ítems
@export var sheet_combate: Texture2D   # El traje para el modo pelea
@onready var en_combate: bool = false


func _ready() -> void:

	menu.process_mode = Node.PROCESS_MODE_DISABLED
	menu.visible = false
	
	anim_tree.active = true
	if $InteractionRayCast:
		$InteractionRayCast.add_exception(self)
	
	# Llamamos a la configuración de límites al iniciar
	# Usamos call_deferred para asegurar que el mapa ya esté cargado en el árbol
	call_deferred("setup_camera_limits")

func setup_camera_limits() -> void:
	# Buscamos el nodo 'Suelo' en la escena del mapa. 
	# Según tu captura image_920a85.png, está un nivel arriba del Player
	var suelo = get_tree().current_scene.find_child("Suelo", true, false)
	
	if suelo and suelo is TileMapLayer:
		var map_limits = suelo.get_used_rect()
		var cell_size = suelo.tile_set.tile_size
		
		# Aplicamos los límites calculados en píxeles
		camera.limit_left = map_limits.position.x * cell_size.x
		camera.limit_right = map_limits.end.x * cell_size.x
		camera.limit_top = map_limits.position.y * cell_size.y
		camera.limit_bottom = map_limits.end.y * cell_size.y
		print("Límites de cámara definidos correctamente para el Pueblo de Yare")
	else:
		push_warning("No se encontró el nodo 'Suelo' para calcular los límites de la cámara")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu_en_partida"):
		toggle_menu()
	
	if en_combate:
		manejar_baile()
	else:
		manejar_movimiento()
func manejar_movimiento() -> void:
	var current_velocity = velocity 
	if current_velocity.length() == 0:
		state_machine.travel("idle")
		anim_tree.set("parameters/Idle/blend_position", get_last_direction())
	else:
		state_machine.travel("walk")
		var move_dir = current_velocity.normalized()
		anim_tree.set("parameters/walk/blend_position", move_dir)
		anim_tree.set("parameters/idle/blend_position", move_dir)
func manejar_baile() -> void:
	velocity = Vector2.ZERO # Inmovilizamos al personaje
	# Disparadores para las animaciones que creaste
	if Input.is_action_just_pressed("ui_up"):
		state_machine.travel("jump")
	elif Input.is_action_just_pressed("ui_down"):
		state_machine.travel("crouch")
	elif Input.is_action_just_pressed("ui_left"):
		state_machine.travel("left")
	elif Input.is_action_just_pressed("ui_right"):
		state_machine.travel("right")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
			print("Tecla presionada: ", event.as_text()) 

	if event.is_action_pressed("interact"):
			print("Accion de interact detecta en gdscript")
			interact()

	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		en_combate = !en_combate # Alternar modo
		print("Modo Combate: ", en_combate)
		
		if en_combate:
			state_machine.travel("idle_combate") # Iniciar baile
		else:
			state_machine.travel("idle") # Volver a caminar

func toggle_menu() -> void:
	# Aplicamos la lógica de inversión booleana para el menú
	menu.visible = !menu.visible
	menu.process_mode = Node.PROCESS_MODE_INHERIT if menu.visible else Node.PROCESS_MODE_DISABLED
	
