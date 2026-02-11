extends Node

# --- PERSISTENCIA DE MOVIMIENTO (¡No borrar!) ---
var last_player_pos = Vector2.ZERO
var target_spawn_id = "" # Indispensable para que los portales funcionen

# --- ESTADO DE MISIONES ---
var mascara_completada = false
var traje_completado = false

# --- INVENTARIO ---
# Nota: Cambié 'inventory' por 'inventario' para que coincida con tus diálogos
var inventario = [] 

# --- FUNCIONES PARA DIALOGUE MANAGER ---
# Estas funciones las llamaremos desde el archivo .dialogue usando 'do'

func fabricar_mascara():
	mascara_completada = true
	# Eliminamos los materiales para que se "gasten" al fabricar
	inventario.erase("papel_mache")
	inventario.erase("pote_pintura")
	print("Misión de máscara finalizada: angel ya tiene su máscara.")

func fabricar_traje():
	traje_completado = true
	# Eliminamos el velón al terminar la misión de la Anciana
	inventario.erase("velon")
	print("Misión de traje finalizada: angel ya tiene su traje.")

# --- UTILIDAD PARA RECOGER OBJETOS ---
func añadir_item(nombre_item: String):
	if not nombre_item in inventario:
		inventario.append(nombre_item)
		print("Objeto guardado en el Global: ", nombre_item)
