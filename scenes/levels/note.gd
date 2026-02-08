extends Node2D

var speed = 0.0
var type = 0

# --- CARGAMOS TUS IMÁGENES ---
# Ajusta la ruta "res://..." a donde hayas guardado tus archivos realmente
var textures = [
	preload("res://assets/art/sprites/leftnote.png"),      # 0 = Izquierda
	preload("res://assets/art/sprites/downnote.png"),     # 1 = Abajo
	preload("res://assets/art/sprites/upnote.png"),    # 2 = Arriba
	preload("res://assets/art/sprites/rightnote.png"),     # 3 = Derecha
	preload("res://assets/art/sprites/cruznote.png")  # 4 = Redención (E)
]




func setup(p_type, p_speed, _p_hit_time):
	type = p_type
	speed = p_speed
	
	# Asignamos la imagen correcta al Sprite
	if type >= 0 and type < textures.size():
		$Sprite2D.texture = textures[type]
	
	# AJUSTE DE TAMAÑO (Opcional por código)
	# Si las imágenes son muy grandes, forzamos la escala aquí:
	$Sprite2D.scale = Vector2(0.045, 0.045) 

func _process(delta):
	# Movimiento hacia la izquierda
	position.x -= speed * delta

	# Si se sale de la pantalla por la izquierda, muere
	if position.x < -100:
		queue_free()
