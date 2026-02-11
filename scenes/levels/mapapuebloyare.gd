extends Node2D


func _ready():
	if Global.target_spawn_id != "":
		print("Intentando aparecer en: ", Global.target_spawn_id) # Esto saldrá en la consola
		
		var punto_donde_llegar = get_node_or_null(Global.target_spawn_id)
		if punto_donde_llegar != null:
			# Movemos al jugador y forzamos a la cámara a seguirl
			$PlayerCharacter.global_position = punto_donde_llegar.global_position
			print("¡Éxito! Personaje movido a ", punto_donde_llegar.name)
		else:
			# Si esto sale en rojo abajo, es que el nombre está mal escrito
			push_error("ERROR: No encontré el nodo llamado " + Global.target_spawn_id)
		
		# IMPORTANTE: Limpiar el ID siempre al f
		Global.target_spawn_id = ""
