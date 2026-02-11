extends Area2D

@export_file("*.tscn") var escena_destino: String
@export var marker_al_llegar: String = "Spawn_Entrada_Casa" # Aquí escribiremos el nombre del Marker2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		# 1. Le decimos al "Cerebro" Global a qué Marker debe ir al cargar
		Global.target_spawn_id = marker_al_llegar
		
		# 2. Cambiamos de escena con seguridad
		call_deferred("cambiar_nivel")

func cambiar_nivel() -> void:
	get_tree().change_scene_to_file(escena_destino)
