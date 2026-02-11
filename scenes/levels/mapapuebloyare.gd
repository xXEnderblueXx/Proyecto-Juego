extends Node2D

func _ready():
	# 1. VERIFICAR SI VENIMOS DE UN PORTAL
	if Global.target_spawn_id != "":
		# Buscamos el Area2D (ej: "DesdeCasaArtesano")
		var area_spawn = get_node_or_null(Global.target_spawn_id)
		
		if area_spawn:
			# --- SOLUCIÓN AL BUCLE ---
			# En lugar de aparecer en el centro (0,0) del área, 
			# aparecemos 20 píxeles más abajo para no tocar la colisión.
			var posicion_segura = area_spawn.global_position + Vector2(0, 20)
			
			$PlayerCharacter.global_position = posicion_segura
			
			# Limpiamos el ID para el próximo viaje
			Global.target_spawn_id = ""
		else:
			print("Error: No encontré el área de spawn: ", Global.target_spawn_id)
