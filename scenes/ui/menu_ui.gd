extends Control

func _ready() -> void:
	$MarginContainer/menuOpciones.process_mode = Node.PROCESS_MODE_DISABLED
	$MarginContainer/menuOpciones.visible = false

func _on_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/mapaversionnueva.tscn")


func _on_opciones_pressed() -> void:
	$MarginContainer/menuInicio.process_mode = Node.PROCESS_MODE_DISABLED
	$MarginContainer/menuInicio.visible = false
	$MarginContainer/menuOpciones.process_mode = Node.PROCESS_MODE_INHERIT
	$MarginContainer/menuOpciones.visible = true
	
func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_volver_pressed() -> void:
	$MarginContainer/menuInicio.process_mode = Node.PROCESS_MODE_INHERIT
	$MarginContainer/menuInicio.visible = true
	$MarginContainer/menuOpciones.process_mode = Node.PROCESS_MODE_DISABLED
	$MarginContainer/menuOpciones.visible = false
