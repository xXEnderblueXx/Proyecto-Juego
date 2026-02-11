# Script para el nodo raíz de la escena iglesia.tscn
extends Node2D

func _ready():
	# Si venimos de un portal, nos movemos al punto indicado
	if Global.target_spawn_id != "":
		var punto_aparicion = get_node_or_null(Global.target_spawn_id)
		if punto_aparicion:
			$PlayerCharacter.global_position = punto_aparicion.global_position
			Global.target_spawn_id = "" # Limpiamos la memoria
