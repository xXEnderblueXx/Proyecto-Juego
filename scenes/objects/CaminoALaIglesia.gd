# Script para el portal CaminoALaIglesia
extends Area2D

@export_file("*.tscn") var escena_destino: String
@export var marker_al_llegar: String = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		# ¡EL GUARDIÁN!
		# Verificamos en el Global si ya tenemos la máscara y el traje
		if Global.mascara_completada and Global.traje_completado:
			Global.target_spawn_id = marker_al_llegar
			call_deferred("cambiar_nivel")
		else:
			# Aquí puedes disparar tu sistema de diálogos para avisar al jugador
			print("No puedes entrar al atrio de la iglesia sin tu disfraz de diablo.")

func cambiar_nivel() -> void:
	get_tree().change_scene_to_file(escena_destino)
