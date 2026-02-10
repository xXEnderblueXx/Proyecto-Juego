extends Node2D

# --- CONFIGURACIÓN ---
@export var pixels_per_second: float = 300.0
const MAX_SCORE = 1000000.0

# --- VARIABLES DE JUEGO ---
var current_score: float = 0.0
var current_combo: int = 0
var score_per_note: float = 0.0
var stats = {"Perfect": 0, "Excellent": 0, "Good": 0, "Meh": 0, "Miss": 0}
var hp: float = 100.0

# --- REFERENCIAS ---
@onready var rhythm_manager = $RhythmManager
@onready var music_player = $AudioStreamPlayer
@onready var notes_container = $UI_Layer/HUD/NotesContainer
@onready var hit_zone = $UI_Layer/HUD/Hitzone
var note_scene = preload("res://scenes/levels/note.tscn") 

# UI
@onready var health_bar = $UI_Layer/HUD/HealthBar
@onready var difficulty_screen = $UI_Layer/DifficultySelect
@onready var loading_screen = $UI_Layer/LoadingScreen
@onready var hud = $UI_Layer/HUD
@onready var results_screen = $UI_Layer/ResultsScreen
@onready var pause_menu = $UI_Layer/HUD/PauseMenu
@onready var btn_resume = $UI_Layer/HUD/PauseMenu/BtnResume

enum GameState { SELECTION, LOADING, PLAYING, PAUSED, RESULTS } 
var current_state = GameState.SELECTION

func _ready():
	# Conexión con C++ (4 parámetros)
	rhythm_manager.spawn_note.connect(_on_note_spawned)
	
	# Conexión para saber cuándo termina la canción
	music_player.finished.connect(_on_song_finished)
	
	# Conexión de botones de dificultad
	var base_path = "res://scenes/levels/recordings/"
	$UI_Layer/DifficultySelect/Facil.pressed.connect(func(): _on_difficulty_chosen(base_path + "boss_facil.json"))
	$UI_Layer/DifficultySelect/Medio.pressed.connect(func(): _on_difficulty_chosen(base_path + "boss_medio.json"))
	$UI_Layer/DifficultySelect/Dificil.pressed.connect(func(): _on_difficulty_chosen(base_path + "boss_dificil.json"))
	$UI_Layer/DifficultySelect/Yare.pressed.connect(func(): _on_difficulty_chosen(base_path + "boss_yare.json"))
	# Botones de Resultados
	$UI_Layer/ResultsScreen/ButtonsContainer/BtnRetry.pressed.connect(_on_retry_pressed)
	$UI_Layer/ResultsScreen/ButtonsContainer/BtnMenu.pressed.connect(_on_menu_pressed)
	#Botones de Pausa
	$UI_Layer/HUD/PauseMenu/BtnResume.pressed.connect(func(): change_state(GameState.PLAYING))
	$UI_Layer/HUD/PauseMenu/BtnRetry.pressed.connect(_on_retry_pressed)
	$UI_Layer/HUD/PauseMenu/BtnMenu.pressed.connect(_on_menu_pressed)
	change_state(GameState.SELECTION)

# --- FUNCIONES DE NAVEGACIÓN ---
func _on_retry_pressed():
	get_tree().paused = false
	# Recarga la escena actual de Gameplay desde cero
	get_tree().reload_current_scene()
func _on_menu_pressed():
	get_tree().paused = false
	# Cambia a tu escena de menú principal (ajusta la ruta según tu proyecto)
	get_tree().change_scene_to_file("res://scenes/menu_ui.tscn")

func _process(delta):
	if current_state == GameState.PLAYING:
		var song_time = music_player.get_playback_position()
		
		# USAMOS EL CENTRO PARA EL DESTINO EN X
		var target_center_x = get_hitzone_center().x
		
		hp -= 0.5 * delta 
		$UI_Layer/HUD/HealthBar.value = hp
		health_bar.value = hp
		if hp <= 0: _on_song_finished() 
		
		for note in notes_container.get_children():
			if "hit_time" in note:
				# Ahora la nota viaja hacia el centro exacto del cuadro
				note.position.x = target_center_x + (note.hit_time - song_time) * pixels_per_second
				
				if note.position.x < target_center_x - 100:
					_aplicar_resultado("Miss", 0.0, note)

func _on_difficulty_chosen(full_path: String):
	# 1. Cargamos el nivel en el Manager de C++
	rhythm_manager.load_level(full_path) 
	
	# 2. REINICIO DE ESTADO (Para empezar limpio cada vez)
	current_score = 0.0
	current_combo = 0
	hp = 100.0
	stats = {"Perfect": 0, "Excellent": 0, "Good": 0, "Meh": 0, "Miss": 0}
	
	# Actualizamos la UI inmediatamente
	$UI_Layer/HUD/ScoreLabel.text = "0000000"
	$UI_Layer/HUD/ComboLabel.text = "x0"
	$UI_Layer/HUD/HealthBar.value = 100
	
	# 3. Calcular puntos por nota para llegar al millón
	var total_notes = rhythm_manager.get_all_notes().size()
	score_per_note = MAX_SCORE / total_notes if total_notes > 0 else 0
	
	# 4. Secuencia de carga
	change_state(GameState.LOADING)
	await get_tree().create_timer(1.5).timeout 
	change_state(GameState.PLAYING)

func _input(event):
# Detectar Tecla Pausa (Esc)
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			change_state(GameState.PAUSED)
		elif current_state == GameState.PAUSED:
			change_state(GameState.PLAYING)

	if current_state == GameState.PLAYING and event is InputEventKey and event.pressed and not event.is_echo():
		var type = _get_input_type(event)
		if type != -1: _verificar_hit(type)

func _verificar_hit(type: int):
	var time = music_player.get_playback_position()
	for n in notes_container.get_children():
		if n.type == type:
			var diff = abs(time - n.hit_time)
			if diff < 0.15: # Ventana máxima
				_calificar_hit(diff, n)
				return

func _calificar_hit(diff: float, note: Node):
	if diff <= 0.03: _aplicar_resultado("Perfect", 1.0, note)
	elif diff <= 0.06: _aplicar_resultado("Excellent", 0.8, note)
	elif diff <= 0.10: _aplicar_resultado("Good", 0.5, note)
	else: _aplicar_resultado("Meh", 0.2, note)

func _aplicar_resultado(rating: String, multiplier: float, note: Node):
	if rating == "Miss":
		current_combo = 0
		hp -= 10.0
		stats["Miss"] += 1
	else:
		current_score += score_per_note * multiplier
		current_combo += 1
		stats[rating] += 1
		var recovery = 2.0 * multiplier
		hp = min(hp + recovery, 100.0)
		
		# Si es tecla E (tipo 4), podrías disparar algo especial aquí
		if note.type == 4: pass 

	# Actualizar UI
	$UI_Layer/HUD/ScoreLabel.text = str(int(current_score)).pad_zeros(7)
	$UI_Layer/HUD/ComboLabel.text = "x" + str(current_combo)
	note.queue_free()

func get_hitzone_center() -> Vector2:
	# Tomamos la posición + la mitad del tamaño para llegar al centro
	return hit_zone.position + (hit_zone.size / 2.0)
	
func _on_note_spawned(type, speed, hit_time, _id):
	var n = note_scene.instantiate()
	notes_container.add_child(n)
	n.setup(type, speed, hit_time)
	n.hit_time = hit_time
	n.position.y = hit_zone.position.y
	
func _get_input_type(event):
	if event.is_action_pressed("ui_left"): return 0
	if event.is_action_pressed("ui_down"): return 1
	if event.is_action_pressed("ui_up"): return 2
	if event.is_action_pressed("ui_right"): return 3
	if event.is_action_pressed("interact"): return 4
	return -1

# --- SISTEMA DE RESULTADOS ---
func _on_song_finished():
	music_player.stop()
	await get_tree().create_timer(1.0).timeout
	change_state(GameState.RESULTS)
	_mostrar_pantalla_resultados()

func _mostrar_pantalla_resultados():
	var res = results_screen
	var stats_cont = res.get_node("StatsContainer")
	
	# El Label principal ahora muestra el Rango (SS, S, A...)
	res.get_node("Label").text = calcular_rango_final()
	
	# Mostramos los conteos finales
	stats_cont.get_node("PerfectCount").text = "Perfect: " + str(stats["Perfect"])
	stats_cont.get_node("ExcellentCount").text = "Excellent: " + str(stats["Excellent"])
	stats_cont.get_node("GoodCount").text = "Good: " + str(stats["Good"])
	stats_cont.get_node("MehCount").text = "Meh: " + str(stats["Meh"])
	stats_cont.get_node("MissCount").text = "Miss: " + str(stats["Miss"])
	
	# Aseguramos que el mouse sea visible para que angel pueda clickear los botones
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func calcular_rango_final() -> String:
	var porcentaje = (current_score / MAX_SCORE) * 100.0
	if current_score >= 1000000: return "SS"
	if porcentaje >= 95: return "S"
	if porcentaje >= 90: return "A"
	if porcentaje >= 80: return "B"
	if porcentaje >= 70: return "C"
	return "D"

func change_state(new_state):
	current_state = new_state
	
	# Gestión de visibilidad (Añadido PauseMenu)
	difficulty_screen.visible = (new_state == GameState.SELECTION)
	loading_screen.visible = (new_state == GameState.LOADING)
	hud.visible = (new_state == GameState.PLAYING or new_state == GameState.PAUSED)
	pause_menu.visible = (new_state == GameState.PAUSED)
	results_screen.visible = (new_state == GameState.RESULTS)
	
	# Lógica de pausa física y de audio
	match current_state:
		GameState.PAUSED:
			get_tree().paused = true # Detiene el movimiento de nodos
			music_player.stream_paused = true # Pausa la música sin reiniciarla
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		GameState.PLAYING:
			get_tree().paused = false # Reanuda el tiempo
			music_player.stream_paused = false # Reanuda la música
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			
			if not music_player.playing:
				rhythm_manager.set_music_player(music_player)
				rhythm_manager.start_song()
		GameState.RESULTS:
			get_tree().paused = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_btn_menu_pressed() -> void:
	pass # Replace with function body.
