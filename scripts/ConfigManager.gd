extends Node

# Diccionario de resoluciones para fácil acceso
var resoluciones: Dictionary = {
	"900x600": Vector2i(900, 600),
	"1280×720": Vector2i(1280, 720),
	"1920x1080": Vector2i(1920, 1080),

}

func aplicar_resolucion(indice: int):
	if indice < 0 or indice >= resoluciones.size():
		return
		
	var nombre_res = resoluciones.keys()[indice]
	var tamano = resoluciones[nombre_res]
	
	# Cambia el tamaño físico de la ventana
	DisplayServer.window_set_size(tamano)
	
	# Centra la ventana en el monitor
	var centro_pantalla = DisplayServer.screen_get_position() + (DisplayServer.screen_get_size() / 2)
	DisplayServer.window_set_position(centro_pantalla - (tamano / 2))
	
	print("Resolución cambiada a: ", nombre_res)


func cambiar_volumen(nombre_bus: String, valor_lineal: float):
	# Obtenemos el índice del bus por su nombre
	var bus_index = AudioServer.get_bus_index(nombre_bus)
	
	# Ingeniería de Audio: Convertimos 0.0-1.0 a Decibelios
	# linear_to_db evita que el sonido baje de forma brusca
	var volumen_db = linear_to_db(valor_lineal)
	
	AudioServer.set_bus_volume_db(bus_index, volumen_db)
	
	# Si el valor es 0, muteamos el bus por completo
	AudioServer.set_bus_mute(bus_index, valor_lineal <= 0.001)
