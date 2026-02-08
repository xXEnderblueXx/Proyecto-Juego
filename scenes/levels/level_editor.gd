extends Node2D

# Referencias
@onready var manager = $RhythmManager
@onready var audio = $AudioStreamPlayer
@onready var input_nombre = $CanvasLayer/InputNombre
@onready var status_label = $CanvasLayer/StatusLabel
@onready var time_slider = $CanvasLayer/TimeSlider
@onready var time_label = $CanvasLayer/TimeLabel
@onready var btn_pausa = $CanvasLayer/BtnPausa
@onready var input_velocidad = $CanvasLayer/InputVelocidad

# Configuración Visual
var note_scene = preload("res://scenes/levels/note.tscn") 
var pixels_per_second = 300.0 # Zoom de la línea de tiempo
var target_x = 100.0 # Dónde está el golpe

# Variables de Estado
var base_path = "res://scenes/levels/recordings/" 
var is_dragging_slider = false
var duration = 0.0
var loaded_notes_visuals = [] 

func _ready():
	# Crear carpeta si no existe
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("scenes/levels/recordings/"):
		dir.make_dir_recursive("scenes/levels/recordings/")

	manager.set_music_player(audio)
	
	# Configurar Slider
	time_slider.drag_started.connect(_on_slider_drag_started)
	time_slider.drag_ended.connect(_on_slider_drag_ended)
	time_slider.value_changed.connect(_on_slider_seek)
	
	status_label.text = "Carga un nivel para ver la línea de tiempo."

# --- PROCESO PRINCIPAL ---
func _process(_delta): # <--- CORREGIDO: _delta para quitar advertencia
	
	# 1. Si estamos GRABANDO (Recording Mode), detectamos inputs
	if manager.recording_mode:
		_handle_recording_inputs()
		# Al grabar, actualizamos el slider para ver progreso
		if audio.playing:
			time_slider.value = audio.get_playback_position()
			update_time_label(audio.get_playback_position())

	# 2. Si estamos EDITANDO (Timeline Mode)
	else:
		# Actualizar Slider si suena la música y no lo estamos arrastrando
		if audio.stream and audio.playing and not is_dragging_slider:
			var current_time = audio.get_playback_position()
			time_slider.value = current_time
			update_time_label(current_time)

		# ACTUALIZAR POSICIÓN DE TODAS LAS NOTAS VISUALES
		var audio_time = audio.get_playback_position()
		
		# Si está en pausa o detenido, usamos el slider como tiempo maestro
		if not audio.playing and audio.stream:
			audio_time = time_slider.value

		for note in loaded_notes_visuals:
			if not is_instance_valid(note): continue
			
			var note_time = note.get_meta("hit_time")
			
			# Fórmula de Timeline:
			var new_x = target_x + (note_time - audio_time) * pixels_per_second
			
			note.position.x = new_x
			note.position.y = 300 
			note.visible = (new_x > -100 and new_x < 1300)

# --- INPUTS DE GRABACIÓN ---
func _handle_recording_inputs():
	# Solo para visualización rápida al grabar
	var _current_speed = 500.0 # Valor dummy
	
	if Input.is_action_just_pressed("ui_left"): manager.register_input(0)
	elif Input.is_action_just_pressed("ui_down"): manager.register_input(1)
	elif Input.is_action_just_pressed("ui_up"):   manager.register_input(2)
	elif Input.is_action_just_pressed("ui_right"): manager.register_input(3)
	elif Input.is_action_just_pressed("interact"): manager.register_input(4)

# --- CARGAR NIVEL ---
func _on_btn_cargar_pressed():
	var file_name = "boss_" + input_nombre.text + ".json"
	var full_path = base_path + file_name
	
	if not FileAccess.file_exists(full_path):
		status_label.text = "❌ No existe."
		return

	manager.load_level(full_path)
	
	if audio.stream:
		duration = audio.stream.get_length()
		time_slider.max_value = duration
		time_slider.step = 0.01

	# Limpiar visuales viejas
	for n in loaded_notes_visuals:
		if is_instance_valid(n): n.queue_free()
	loaded_notes_visuals.clear()

	# Crear visuales nuevas desde C++
	var all_data = manager.get_all_notes()
	print("DEBUG: C++ devolvió ", all_data.size(), " notas.")
	var index = 0
	
	for data in all_data:
		var new_note = note_scene.instantiate()
		add_child(new_note)
		
		var type = int(data["type"])
		var time = float(data["time"])
		
		new_note.set_meta("id", index)
		new_note.set_meta("hit_time", time)
		new_note.setup(type, 0, time)
		
		loaded_notes_visuals.append(new_note)
		index += 1
		
	status_label.text = "Timeline cargada. Arrastra la barra."
	_pausar_juego()

# --- BOTÓN GRABAR ---
func _on_btn_grabar_pressed():
	if input_nombre.text == "": return
	status_label.text = "🔴 GRABANDO..."
	
	# Borramos visuales viejas para limpiar pantalla
	for n in loaded_notes_visuals: if is_instance_valid(n): n.queue_free()
	loaded_notes_visuals.clear()
	
	manager.recording_mode = true
	manager.start_song()
	get_viewport().set_input_as_handled()

# --- BOTÓN GUARDAR ---
func _on_btn_guardar_pressed():
	if input_nombre.text == "": return
	var full_path = base_path + "boss_" + input_nombre.text + ".json"
	manager.save_recording(full_path)
	status_label.text = "✅ GUARDADO."

# --- BOTÓN PAUSA ---
func _on_btn_pausa_pressed():
	if audio.stream_paused:
		# REANUDAR
		audio.stream_paused = false
		get_tree().paused = false
		btn_pausa.text = "⏸️ PAUSA"
	else:
		_pausar_juego()
	btn_pausa.release_focus()

func _pausar_juego():
	audio.stream_paused = true
	get_tree().paused = true
	btn_pausa.text = "▶️ PLAY"

# --- SLIDER ---
func _on_slider_drag_started():
	is_dragging_slider = true

func _on_slider_drag_ended(_value_changed): # <--- CORREGIDO: _value_changed
	is_dragging_slider = false
	audio.seek(time_slider.value)

func _on_slider_seek(value):
	update_time_label(value)
	if not audio.playing:
		pass # <--- CORREGIDO: Agregamos 'pass' para que no de error

func update_time_label(time):
	var mins = int(time / 60)
	var secs = int(time) % 60
	var mills = int((time - int(time)) * 100)
	time_label.text = "%02d:%02d:%02d" % [mins, secs, mills]

# --- EDICIÓN ---
func notify_note_moved(note_node):
	var id = note_node.get_meta("id")
	
	var audio_time = time_slider.value
	var offset_x = note_node.position.x - target_x
	var time_diff = offset_x / pixels_per_second
	
	var new_time = audio_time + time_diff
	
	manager.update_note_time(id, new_time)
	note_node.set_meta("hit_time", new_time)
	status_label.text = "Nota movida: " + str(snapped(new_time, 0.01))
