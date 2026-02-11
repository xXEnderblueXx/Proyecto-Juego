extends Area2D

# Configúralos desde el Inspector de cada portal
@export_file("*.tscn") var escena_destino: String
@export var marker_al_llegar: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		# Guardamos en el "cerebro" Global el nombre del marcador de destino
		Global.target_spawn_id = marker_al_llegar
		
		# Cambiamos de escena
		if escena_destino != "":
			get_tree().change_scene_to_file(escena_destino)
