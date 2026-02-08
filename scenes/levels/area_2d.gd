extends StaticBody2D
func activar():
		print("¡FUNCIONÓ! Interacción exitosa con el Área.")
@export var next_map: String


func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCharacter":
		get_tree().change_scene_to_file(next_map)
