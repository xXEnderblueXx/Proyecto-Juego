extends Node2D

# Referencias
@onready var manager = $RhythmManager
@onready var audio = $AudioStreamPlayer
@onready var input_nombre = $CanvasLayer/InputNombre
@onready var status_label = $CanvasLayer/StatusLabel
@onready var time_slider = $CanvasLayer/TimeSlider
@onready var time_label = $CanvasLayer/TimeLabel
@onready var btn_pausa = $CanvasLayer/BtnPausa

# Configuración Visual
var note_scene = preload("res://scenes/levels/note.tscn") 
var pixels_per_second = 300.0 # Zoom de la línea de tiempo (Editable)
var target_x = 100.0 # Dónde está el golpe (Izquierda)

# Variables de Estado
var base_path = "res://scenes/levels/recordings/" 
var is_dragging_slider = false
var duration = 0.0
var loaded_notes_visuals = [] # Array para guardar referencias a los nodos visuales

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

# --- PROCESO PRINCIPAL (EL CORAZÓN DEL EDITOR) ---
func _process(delta):
	# 1. Actualizar Slider y Texto (Solo si no lo estamos arrastrando)
	if audio.stream and not is_dragging_slider:
		var current_time = audio.get_playback_position()
		time_slider.value = current_time
		update_time_label(current_time)

	# 2. ACTUALIZAR POSICIÓN DE TODAS LAS NOTAS VISUALES
	# Esto ocurre en cada frame. Recalculamos dónde debe estar cada nota.
	var audio_time = audio.get_playback_position()
	
	# Si el audio no está sonando pero estamos en pausa, usamos el valor del slider
	if not audio.playing and audio.stream:
		audio_time = time_slider.value

	for note in loaded_notes_visuals:
		# Si la nota fue borrada (queue_free), saltarla
		if not is_instance_valid(note): continue
		
		var note_time = note.get_meta("hit_time")
		
		# --- LA FÓRMULA MAESTRA ---
		# Posición = Meta + (DiferenciaDeTiempo * Zoom)
		var new_x = target_x + (note_time - audio_time) * pixels_per_second
		
		note.position.x = new_x
		note.position.y = 300 # O la altura según su tipo

		# Optimización: Ocultar si está muy lejos de la pantalla
		note.visible = (new_x > -100 and new_x < 1300)

# --- CARGAR NIVEL Y DIBUJAR TODO ---
func _on_btn_cargar_pressed():
	# ... (Validaciones de archivo igual que antes) ...
	var file_name = "boss_" + input_nombre.text + ".json"
	var full_path = base_path + file_name
	
	if not FileAccess.file_exists(full_path):
		status_label.text = "❌ No existe."
		return

	# 1. Cargar datos en C++
	manager.load_level(full_path)
	
	# 2. Configurar Slider con la duración de la canción
	if audio.stream:
		duration = audio.stream.get_length()
		time_slider.max_value = duration
		time_slider.step = 0.01 # Precisión de centésimas

	# 3. LIMPIEZA: Borrar notas viejas visuales
	for n in loaded_notes_visuals:
		if is_instance_valid(n): n.queue_free()
	loaded_notes_visuals.clear()

	# 4. GENERACIÓN MASIVA: Crear todas las notas visuales
	var all_data = manager.get_all_notes() # ¡Usamos la nueva función de C++!
	var index = 0
	
	for data in all_data:
		var new_note = note_scene.instantiate()
		add_child(new_note)
		
		var type = int(data["type"])
		var time = float(data["time"])
		
		# Configuramos datos
		new_note.set_meta("id", index)
		new_note.set_meta("hit_time", time) # Guardamos el tiempo original
		new_note.setup(type, 0, time) # Velocidad 0 porque la controlamos nosotros
		
		loaded_notes_visuals.append(new_note)
		index += 1
		
	status_label.text = "timeline cargada. Arrastra la barra."
	
	# Pausamos automáticamente al cargar para editar tranquilo
	_pausar_juego()

# --- CONTROL DEL SLIDER (BUSCADOR) ---
func _on_slider_drag_started():
	is_dragging_slider = true

func _on_slider_drag_ended(value_changed):
	is_dragging_slider = false
	# Al soltar, saltamos al segundo exacto
	audio.seek(time_slider.value)

func _on_slider_seek(value):
	# Si arrastramos, actualizamos la etiqueta tiempo real
	update_time_label(value)
	
	# Si estamos pausados, forzamos actualización visual de notas aquí también
	if not audio.playing:
		pass # <--- AGREGAMOS ESTO. Significa "No hagas nada aquí, continúa".
		# El _process se encarga de mover las notas, así que el pass es suficiente.
# --- UTILIDADES ---
func _pausar_juego():
	audio.stream_paused = true
	get_tree().paused = true
	btn_pausa.text = "▶️ PLAY"

func update_time_label(time):
	var mins = int(time / 60)
	var secs = int(time) % 60
	var mills = int((time - int(time)) * 100)
	time_label.text = "%02d:%02d:%02d" % [mins, secs, mills]

# --- EDICIÓN (ARRASTRAR NOTAS) ---
# Llamado desde Note.gd cuando sueltas una nota
func notify_note_moved(note_node):
	var id = note_node.get_meta("id")
	
	# Matemática Inversa para hallar el nuevo tiempo
	# PosX = Target + (NoteTime - AudioTime) * PPS
	# (PosX - Target) / PPS = NoteTime - AudioTime
	# NoteTime = ((PosX - Target) / PPS) + AudioTime
	
	var audio_time = time_slider.value
	var offset_x = note_node.position.x - target_x
	var time_diff = offset_x / pixels_per_second
	
	var new_time = audio_time + time_diff
	
	# Actualizar C++
	manager.update_note_time(id, new_time)
	
	# Actualizar el metadato visual también para que no salte
	note_node.set_meta("hit_time", new_time)
	
	status_label.text = "Nota movida a: " + str(snapped(new_time, 0.01))
