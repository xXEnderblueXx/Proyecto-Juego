extends Control

@onready var inicio = $MarginContainer/menuInicio
@onready var opciones = $MarginContainer/menuOpciones
@onready var resolution = $MarginContainer/resolutions

func _ready() -> void:
	opciones.process_mode = Node.PROCESS_MODE_DISABLED
	opciones.visible = false

func _on_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/mapapuebloyare.tscn")


func _on_opciones_pressed() -> void:
	inicio.process_mode = Node.PROCESS_MODE_DISABLED
	inicio.visible = false
	opciones.process_mode = Node.PROCESS_MODE_INHERIT
	opciones.visible = true
	
func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_volver_pressed() -> void:
	inicio.process_mode = Node.PROCESS_MODE_INHERIT
	inicio.visible = true
	opciones.process_mode = Node.PROCESS_MODE_DISABLED
	opciones.visible = false


func _on_full_scream_changed_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
func configurar_selector():
	var selector = $resolutions
	selector.clear()
	# Este bucle añade las 3 resoluciones automáticamente en orden
	for nombre in CONFIGMANAGER.resoluciones.keys():
		selector.add_item(nombre)


func _on_video_pressed() -> void:
	resolution.process_mode = Node.PROCESS_MODE_INHERIT
	resolution.visible = true


func _on_audio_pressed() -> void:
	pass

func _on_x_600_pressed() -> void:
	CONFIGMANAGER.aplicar_resolucion(0) 


func _on__pressed() -> void:
	CONFIGMANAGER.aplicar_resolucion(1) 


func _on_x_1080_pressed() -> void:
	CONFIGMANAGER.aplicar_resolucion(2) 
	
