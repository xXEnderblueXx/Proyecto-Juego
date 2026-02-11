extends Sprite2D

@export var nombre_del_objeto: String = ""

func _ready():
	# PERSISTENCIA: Si el objeto ya está en el inventario, lo borramos del mapa
	# al cargar la escena para que no aparezca de nuevo
	if nombre_del_objeto in Global.inventario:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("jugador"):
		# Lo guardamos en el cerebro global
		Global.añadir_item(nombre_del_objeto)
		
		# (Opcional) Aquí podrías activar un sonido de "pick up"
		
		# Lo eliminamos de la escena actual
		queue_free()
