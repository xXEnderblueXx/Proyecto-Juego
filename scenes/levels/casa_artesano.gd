extends Node2D

func _ready():
	# Buscamos si el Global trae una instrucción de dónde aparecer
	if Global.target_spawn_id != "":
		var punto_inicio = get_node_or_null(Global.target_spawn_id)
		if punto_inicio:
			$PlayerCharacter.global_position = punto_inicio.global_position
			Global.target_spawn_id = "" # Limpiamos para el siguiente viaje


func _on_salida_casa_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
