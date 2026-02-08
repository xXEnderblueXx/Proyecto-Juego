extends Node2D

# Variables de identificación
var type = 0
var hit_time = 0.0 # Guardamos el tiempo exacto en la canción

# Variables para interacción con Mouse
var is_dragging = false

# --- TUS TEXTURAS ---
var textures = [
	preload("res://assets/art/sprites/leftnote.png"),      # 0
	preload("res://assets/art/sprites/downnote.png"),     # 1
	preload("res://assets/art/sprites/upnote.png"),    # 2
	preload("res://assets/art/sprites/rightnote.png"),     # 3
	preload("res://assets/art/sprites/cruznote.png")  # 4
]

func setup(p_type, _p_speed, p_hit_time):
	type = p_type
	# Nota: Ya no usamos 'speed' aquí porque el LevelEditor controla la posición
	hit_time = p_hit_time
	
	# Asignamos la imagen correcta
	if type >= 0 and type < textures.size():
		$Sprite2D.texture = textures[type]
	
	# Tu escala personalizada
	$Sprite2D.scale = Vector2(0.045, 0.045) 

func _process(_delta):
	# --- NUEVO COMPORTAMIENTO ---
	# Si la estoy arrastrando con el mouse, sigo al mouse
	if is_dragging:
		position.x = get_global_mouse_position().x
	
	# SI NO LA ARRASTRO: ¡No hago nada! 
	# El level_editor.gd se encarga de calcular mi posición exacta.

# --- DETECTAR CLIC PARA ARRASTRAR ---
func _input(event):
	# Solo permitimos editar si el mouse se mueve o clica
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# ¿Clic sobre mí? (Radio de detección aprox 40px)
				if get_global_mouse_position().distance_to(global_position) < 40:
					is_dragging = true
					modulate = Color(1, 1, 0) # Se pone amarilla al agarrar
			else:
				# Soltar clic
				if is_dragging:
					is_dragging = false
					modulate = Color(1, 1, 1) # Color normal
					
					# AVISAMOS AL EDITOR QUE NOS MOVIERON PARA QUE RECALCULE EL TIEMPO
					var editor = get_parent()
					if editor.has_method("notify_note_moved"):
						editor.notify_note_moved(self)
