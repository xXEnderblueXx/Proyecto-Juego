extends Node2D

# Referencias a los nodos
@onready var manager = $RhythmManager
@onready var audio = $AudioStreamPlayer
@onready var input_nombre = $CanvasLayer/InputNombre
@onready var status_label = $CanvasLayer/StatusLabel
@onready var input_velocidad = $CanvasLayer/InputVelocidad
@onready var btn_pausa = $CanvasLayer/BtnPausa
@onready var spawn_point = $SpawnPoint

# Pre-carga de la escena de la nota
var note_scene = preload("res://scenes/levels/note.tscn") 

var base_path = "res://scenes/levels/recordings/" 
var is_paused = false 

func _ready():
	# Crear carpeta si no existe
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("scenes/levels/recordings/"):
		dir.make_dir_recursive("scenes/levels/recordings/")

	manager.set_music_player(audio)
	
	# Conectamos la señal para DIBUJAR las notas
	if manager.has_signal("spawn_note"):
		manager.connect("spawn_note", _on_spawn_note_visual)
	
	status_label.text = "Escribe dificultad, GRABAR para crear."

# --- BOTÓN GRABAR ---
func _on_btn_grabar_pressed():
	if input_nombre.text == "":
		status_label.text = "⚠️ ¡Escribe un nombre primero!"
		return
		
	status_label.text = "🔴 GRABANDO: " + input_nombre.text
	
	manager.recording_mode = true
	manager.start_song()
	
	get_viewport().set_input_as_handled()

# --- BOTÓN GUARDAR ---
func _on_btn_guardar_pressed():
	if input_nombre.text == "":
		status_label.text = "⚠️ No hay nombre de archivo."
		return

	var file_name = "boss_" + input_nombre.text + ".json"
	var full_path = base_path + file_name
	
	manager.save_recording(full_path)
	status_label.text = "✅ ¡GUARDADO! " + file_name

# --- BOTÓN CARGAR ---
func _on_btn_cargar_pressed():
	if input_nombre.text == "":
		status_label.text = "⚠️ Escribe nombre para cargar."
		return

	var file_name = "boss_" + input_nombre.text + ".json"
	var full_path = base_path + file_name
	
	if not FileAccess.file_exists(full_path):
		status_label.text = "❌ Archivo no existe."
		return

	manager.load_level(full_path)
	status_label.text = "📂 CARGADO. Jugando..."
	
	manager.recording_mode = false 
	manager.start_song()

# --- BOTÓN PAUSA ---
func _on_btn_pausa_pressed():
	is_paused = !is_paused 
	
	if is_paused:
		get_tree().paused = true 
		audio.stream_paused = true
		manager.set_process(false) 
		$CanvasLayer/BtnPausa.text = "▶️ REANUDAR"
		status_label.text = "⏸️ PAUSADO"
	else:
		get_tree().paused = false 
		audio.stream_paused = false
		manager.set_process(true)
		$CanvasLayer/BtnPausa.text = "⏸️ PAUSA"
		status_label.text = "🟢 SIGUE..."
	
	$CanvasLayer/BtnPausa.release_focus()

# --- DIBUJAR LAS NOTAS (LÓGICA MATEMÁTICA CORREGIDA) ---
func _on_spawn_note_visual(type, speed_from_cpp, hit_time, id):
	var new_note = note_scene.instantiate()
	add_child(new_note)
	
	# 1. Definir posiciones
	var target_x = 100 
	var spawn_x = 1280 
	if spawn_point: 
		spawn_x = spawn_point.position.x
	
	# 2. CALCULAR VELOCIDAD Y POSICIÓN (Separado por modos)
	var dist_total = spawn_x - target_x
	var velocidad_pixels = 0.0
	var tiempo_restante = 0.0
	
	if speed_from_cpp > 0:
		# --- MODO JUGAR/CARGAR ---
		# C++ manda TIEMPO (segundos que tarda en llegar, ej: 2.0s)
		velocidad_pixels = dist_total / speed_from_cpp
		
		# Ajuste fino de posición:
		if hit_time > 0:
			var current_pos = audio.get_playback_position()
			tiempo_restante = hit_time - current_pos
		else:
			tiempo_restante = speed_from_cpp
			
		# Aplicar la posición matemática exacta
		new_note.position.x = target_x + (tiempo_restante * velocidad_pixels)
		
	else:
		# --- MODO GRABAR ---
		# C++ manda 0. Usamos la velocidad directa del Input (ej: 500 px/seg)
		velocidad_pixels = input_velocidad.value
		
		# Al grabar, la nota nace en el spawn y viaja normal
		new_note.position.x = spawn_x

	new_note.position.y = 300 
	
	# Guardamos ID y configuramos
	new_note.set_meta("id", id) 
	new_note.setup(type, velocidad_pixels, hit_time)

# --- INPUTS ---
func _process(_delta):
	if manager.recording_mode:
		
		# Enviamos 4 argumentos dummy (-1 id, 0 time)
		# Nota: Ya no pasamos la velocidad aquí porque _on_spawn_note_visual la lee directo del input
		
		if Input.is_action_just_pressed("ui_left"): 
			manager.register_input(0)
			_on_spawn_note_visual(0, 0, 0, -1) 

		elif Input.is_action_just_pressed("ui_down"): 
			manager.register_input(1)
			_on_spawn_note_visual(1, 0, 0, -1) 

		elif Input.is_action_just_pressed("ui_up"):   
			manager.register_input(2)
			_on_spawn_note_visual(2, 0, 0, -1) 

		elif Input.is_action_just_pressed("ui_right"): 
			manager.register_input(3)
			_on_spawn_note_visual(3, 0, 0, -1) 

		elif Input.is_action_just_pressed("interact"): 
			manager.register_input(4)
			_on_spawn_note_visual(4, 0, 0, -1)
