extends PlayerCharacter

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
# Referencia a la cámara para ajustar los límites
@onready var camera = $Camera2D 

func _ready() -> void:
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
	var current_velocity = velocity 

	if current_velocity.length() == 0:
		state_machine.travel("idle")
		var last_dir = get_last_direction()
		anim_tree.set("parameters/Idle/blend_position", last_dir)
	else:
		state_machine.travel("walk")
		var move_dir = current_velocity.normalized()
		anim_tree.set("parameters/walk/blend_position", move_dir)
		anim_tree.set("parameters/idle/blend_position", move_dir)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
			print("Tecla presionada: ", event.as_text()) 

	if event.is_action_pressed("interact"):
			print("Accion de interact detecta en gdscript")
			interact()
