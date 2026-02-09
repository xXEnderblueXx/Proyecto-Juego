extends Node2D

# --- REFERENCIAS ---
@onready var manager = $RhythmManager
@onready var audio = $AudioStreamPlayer
@onready var input_nombre = $CanvasLayer/InputNombre
@onready var status_label = $CanvasLayer/StatusLabel
@onready var time_slider = $CanvasLayer/TimeSlider
@onready var time_label = $CanvasLayer/TimeLabel
@onready var btn_pausa = $CanvasLayer/BtnPausa

# Referencia al nodo visual de la meta
@onready var spawn_node = $SpawnPoint 

# --- CONFIGURACIÓN ---
var note_scene = preload("res://scenes/levels/note.tscn") 
var pixels_per_second = 300.0 # Velocidad de visualización

# --- ESTADO ---
var base_path = "res://scenes/levels/recordings/" 
var is_dragging_slider = false
var loaded_notes_visuals = [] 

func _ready():
	print("🟢 EDITOR INICIADO - LÓGICA DE SLIDER MEJORADA")
	
	# Asegurar carpetas
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("scenes/levels/recordings/"):
		dir.make_dir_recursive("scenes/levels/recordings/")

	manager.set_music_player(audio)
	
	# Conectar botones (Conexión segura)
	_conectar_boton($CanvasLayer/BtnCargar, _on_btn_cargar_pressed)
	_conectar_boton($CanvasLayer/BtnGrabar, _on_btn_grabar_pressed)
	_conectar_boton($CanvasLayer/BtnGuardar, _on_btn_guardar_pressed)
	_conectar_boton($CanvasLayer/BtnPausa, _on_btn_pausa_pressed)
	
	# Conectar Slider
	time_slider.drag_started.connect(func(): is_dragging_slider = true)
	time_slider.drag_ended.connect(_on_slider_drag_ended)
	time_slider.value_changed.connect(_on_slider_seek)
	
	status_label.text = "Editor Listo. Arrastra la barra para mover las notas."

func _conectar_boton(boton, funcion):
	if boton.pressed.is_connected(funcion): boton.pressed.disconnect(funcion)
	boton.pressed.connect(funcion)

# --- BUCLE PRINCIPAL (LÓGICA ACTUALIZADA) ---
func _process(_delta): 
	if manager.recording_mode and audio.playing:
		_handle_recording_inputs_visuals()
	# 1. DETERMINAR EL TIEMPO ACTUAL
	var audio_time = 0.0

	# Priorizamos el slider si estamos arrastrando O si el audio está en pausa/detenido
	if is_dragging_slider or not audio.playing:
		audio_time = time_slider.value
	else:
		# Si suena la música, el slider sigue a la música
		audio_time = audio.get_playback_position()
		time_slider.value = audio_time

	update_time_label(audio_time)

	# 2. MOVER NOTAS SEGÚN EL SPAWNPOINT
	# Obtenemos posición de la meta (SpawnPoint)
	var target_x = 100.0
	var target_y = 300.0
	
	if spawn_node:
		target_x = spawn_node.position.x
		target_y = spawn_node.position.y

	for note in loaded_notes_visuals:
		if not is_instance_valid(note): continue
		
		# Si el usuario la está arrastrando con el mouse, no la movemos por código
		if "is_dragging" in note and note.is_dragging: continue 
		
		var note_time = note.get_meta("hit_time")
		
		# FÓRMULA DE MOVIMIENTO:
		# Posición = Meta + (Diferencia de tiempo * Velocidad)
		var new_x = target_x + (note_time - audio_time) * pixels_per_second
		
		# Aplicamos posición
		note.position = Vector2(new_x, target_y)
		
		# Optimización: Solo visibles si están cerca del área de juego
		note.visible = (new_x > -500 and new_x < 2500)

# --- SLIDER Y CONTROL DE TIEMPO ---
func _on_slider_drag_ended(_val):
	is_dragging_slider = false
	# Al soltar, sincronizamos el audio al punto donde quedó la barra
	audio.seek(time_slider.value)

func _on_slider_seek(value):
	update_time_label(value)
	# Si el audio NO está sonando, forzamos al audio a ir a ese punto
	# Esto es útil para escuchar un fragmento pequeño si le das play después
	if not audio.playing and audio.stream:
		audio.seek(value)

func update_time_label(t):
	var m = int(t / 60); var s = int(t) % 60; var ms = int((t-int(t))*100)
	time_label.text = "%02d:%02d:%02d" % [m, s, ms]

# --- PAUSA Y REPRODUCCIÓN ---
func _on_btn_pausa_pressed():
	if audio.stream_paused:
		# REANUDAR
		audio.stream_paused = false
		btn_pausa.text = "⏸️ PAUSA"
	else:
		# PAUSAR
		_pausar_juego()
	btn_pausa.release_focus()

func _pausar_juego():
	# Solo pausamos el stream de audio, NO el árbol entero.
	# Esto permite que _process siga corriendo para mover notas con el slider.
	audio.stream_paused = true
	btn_pausa.text = "▶️ PLAY"

# --- VISUALES AL GRABAR ---
func _handle_recording_inputs_visuals():
	var type = -1
	if Input.is_action_just_pressed("ui_left"): type = 0
	elif Input.is_action_just_pressed("ui_down"): type = 1
	elif Input.is_action_just_pressed("ui_up"):   type = 2
	elif Input.is_action_just_pressed("ui_right"): type = 3
	elif Input.is_action_just_pressed("interact"): type = 4
	
	if type != -1:
		manager.register_input(type)
		
		var new_note = note_scene.instantiate()
		add_child(new_note)
		
		var current_time = audio.get_playback_position()
		
		new_note.set_meta("id", -1) 
		new_note.set_meta("hit_time", current_time)
		new_note.setup(type, 0, current_time)
		
		# Posición inicial: En el SpawnPoint
		var s_pos = Vector2(100, 300)
		if spawn_node: s_pos = spawn_node.position
		
		new_note.position = s_pos
		new_note.z_index = 100 
		loaded_notes_visuals.append(new_note)

# --- CARGAR NIVEL ---
func _on_btn_cargar_pressed():
	var path = base_path + "boss_" + input_nombre.text + ".json"
	if not FileAccess.file_exists(path):
		status_label.text = "❌ Archivo no existe."
		return

	manager.load_level(path)
	
	# Limpieza
	for n in loaded_notes_visuals: if is_instance_valid(n): n.queue_free()
	loaded_notes_visuals.clear()

	if audio.stream:
		var duration = audio.stream.get_length()
		time_slider.max_value = duration
		time_slider.step = 0.01

	# Recrear visuales
	var all_data = manager.get_all_notes()
	var idx = 0
	
	var spawn_y = 300.0
	if spawn_node: spawn_y = spawn_node.position.y
	
	for data in all_data:
		var n = note_scene.instantiate()
		add_child(n)
		n.set_meta("id", idx)
		n.set_meta("hit_time", float(data["time"]))
		n.setup(int(data["type"]), 0, float(data["time"]))
		n.position.y = spawn_y
		n.z_index = 100
		loaded_notes_visuals.append(n)
		idx += 1
		
	status_label.text = "Cargadas " + str(idx) + " notas."
	_pausar_juego()

# --- GRABAR / GUARDAR ---
func _on_btn_grabar_pressed():
	if input_nombre.text == "": return
	status_label.text = "🔴 GRABANDO..."
	for n in loaded_notes_visuals: n.queue_free()
	loaded_notes_visuals.clear()
	manager.recording_mode = true
	manager.start_song()
	get_viewport().set_input_as_handled()

func _on_btn_guardar_pressed():
	manager.save_recording(base_path + "boss_" + input_nombre.text + ".json")
	status_label.text = "✅ GUARDADO."

# --- ARRASTRAR NOTAS (EDICIÓN MANUAL) ---
func notify_note_moved(note_node):
	var id = note_node.get_meta("id")
	var audio_pos = time_slider.value
	
	var target_x = 100.0
	if spawn_node: target_x = spawn_node.position.x
	
	var offset_x = note_node.position.x - target_x
	var time_diff = offset_x / pixels_per_second
	var new_time = audio_pos + time_diff
	
	manager.update_note_time(id, new_time)
	note_node.set_meta("hit_time", new_time)
	status_label.text = "Nota ajustada: " + str(snapped(new_time, 0.01))
