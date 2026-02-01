extends Control



func _on_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/mapaversionnueva.tscn")


func _on_opciones_pressed() -> void:
	pass # Replace with function body.


func _on_salir_pressed() -> void:
	get_tree().quit()
<<<<<<< Updated upstream
=======

func _on_volver_pressed() -> void:
	$MarginContainer/menuInicio.process_mode = Node.PROCESS_MODE_INHERIT
	$MarginContainer/menuInicio.visible = true
	$MarginContainer/menuOpciones.process_mode = Node.PROCESS_MODE_DISABLED
	$MarginContainer/menuOpciones.visible = false

#profe si lee esto pongame 20
>>>>>>> Stashed changes
