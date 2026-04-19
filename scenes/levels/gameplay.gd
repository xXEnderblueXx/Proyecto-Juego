extends Node2D

# --- REFERENCIAS ---
@onready var manager = $RhythmManager
@onready var audio = $AudioStreamPlayer
@onready var notes_container = $NotesContainer # El nodo que creamos antes

# Preparamos la escena de la nota para instanciarla
var note_scene = preload("res://scenes/levels/note.tscn")

# --- CONFIGURACIÓN DE NIVELES ---
# Aquí mapeas los nombres de tus dificultades con sus archivos JSON
var dificultades = {
	"Facil": "res://scenes/levels/recordings/boss_facil.json",
	"Medio": "res://scenes/levels/recordings/boss_medio.json",
	"Dificil": "res://scenes/levels/recordings/boss_dificil.json",
	"Yare": "res://scenes/levels/recordings/boss_yare.json"
}

func _ready():
	# 1. Conexión de señales (Ahora sí definiremos la función abajo)
	manager.spawn_note.connect(_on_note_spawned)
	manager.set_music_player(audio)
	
	# 2. Por ahora, para probar, llamamos a una dificultad manualmente
	# En el futuro, esto lo llamará tu menú de selección
	iniciar_nivel("Yare")

func iniciar_nivel(nombre_dificultad: String):
	if dificultades.has(nombre_dificultad):
		var ruta = dificultades[nombre_dificultad]
		print("Cargando nivel: ", nombre_dificultad)
		
		manager.load_level(ruta)
		
		# Aquí podrías poner un Timer de "3, 2, 1... ¡YA!"
		manager.start_song()
	else:
		print("Error: La dificultad ", nombre_dificultad, " no existe.")

# --- ESTA ES LA FUNCIÓN QUE FALTABA ---
# Los parámetros deben coincidir con los que definiste en C++ (type, speed, hit_time, id)
func _on_note_spawned(type: int, speed: float, hit_time: float, id: int): # En esta linea sale una advertencia The parameter "id" is never used in the function "_on_note_spawned()". If this is intended, prefix it with an underscore: "_id".

	# 1. Instanciar la nota visual
	var nueva_nota = note_scene.instantiate()
	
	# 2. Añadirla al contenedor de notas
	notes_container.add_child(nueva_nota)
	
	# 3. Configurar la nota (usando la función setup que ya tienes)
	nueva_nota.setup(type, speed, hit_time)
	
	# 4. Guardar el tiempo de impacto para que el gameplay sepa cuándo debe tocarse
	nueva_nota.set_meta("hit_time", hit_time)
	nueva_nota.set_meta("type", type)
	
	print("Nota visual creada. Tipo: ", type, " Tiempo: ", hit_time)
