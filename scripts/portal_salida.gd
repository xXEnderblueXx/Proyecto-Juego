extends Area2D

# Esta variable expone un selector de archivos en el Inspector.
# El filtro "*.tscn" ayuda a que solo veas escenas.
@export_file("*.tscn") var escena_destino: String

func _on_body_entered(body: Node2D) -> void:
	# 1. Verificación de Grupo:
	# Funciona para Player_Normal, Player_Especial y Player_Combate
	# siempre que los hayas añadido al grupo "jugador".
	if body.is_in_group("jugador"):
		print("¡Portal activado por: ", body.name, "!")
		
		# 2. Validación de Seguridad (Ingeniería defensiva):
		if escena_destino == null or escena_destino == "":
			push_error("ERROR CRÍTICO: Se te olvidó asignar la 'Escena Destino' en el Inspector del Portal.")
			return
		
		# 3. Ejecución Diferida:
		# Vital para evitar crasheos si el cambio ocurre durante un cálculo de físicas.
		call_deferred("cambiar_nivel")

func cambiar_nivel() -> void:
	# Realiza el cambio de escena real
	get_tree().change_scene_to_file(escena_destino)
