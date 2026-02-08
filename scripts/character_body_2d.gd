extends CharacterBody2D

# --- Parámetros de Ingeniería (Configurables desde el Inspector) ---
@export_group("Visuales")
@export var textura_animal: Texture2D # Aquí arrastras el .png de la vaca, pollo o cerdo
@export var h_frames: int = 2        # Cantidad de cuadros en tu spritesheet

@export_group("Lógica de Movimiento")
@export var velocidad: float = 40.0
@export var radio_maximo: float = 120.0 # No se alejará más de esto desde su origen
@export var tiempo_de_cambio: float = 2.0 # Segundos entre cada decisión

# --- Variables de Estado ---
@onready var origen: Vector2 = global_position # Punto de ancla guardado al iniciar
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var anim: AnimationPlayer = $AnimationPlayer

var direccion: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Inicialización dinámica del sprite
	if textura_animal:
		sprite.texture = textura_animal
		sprite.hframes = h_frames
	
	# Configuración del motor de decisiones (Timer)
	timer.wait_time = tiempo_de_cambio
	timer.timeout.connect(_decidir_nuevo_rumbo)
	timer.start()

func _physics_process(_delta: float) -> void:
	# 1. Movimiento Físico (Interacción con colisiones y jugador)
	velocity = direccion * velocidad
	move_and_slide() # Godot resuelve el choque con paredes y jugador automáticamente
	
	# 2. Control de Radio (Fórmula de Contención)
	# Calculamos la distancia euclidiana: d = sqrt((x2-x1)^2 + (y2-y1)^2)
	if global_position.distance_to(origen) > radio_maximo:
		# Si se aleja mucho, lo obligamos a mirar hacia el origen
		direccion = global_position.direction_to(origen)
	
	# 3. Control de Animación
	_gestionar_animaciones()

func _decidir_nuevo_rumbo() -> void:
	# Selección aleatoria de dirección (Arriba, Abajo, Izquierda, Derecha o Quieto)
	var opciones = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.ZERO]
	direccion = opciones.pick_random()

func _gestionar_animaciones() -> void:
	if direccion != Vector2.ZERO:
		# Si hay movimiento, reproduce la animación de caminar
		if anim.has_animation("caminar"):
			anim.play("caminar")
		# Volteo horizontal del sprite según dirección X
		if direccion.x != 0:
			sprite.flip_h = (direccion.x > 0)
	else:
		# Si está quieto, detenemos la animación en el frame 0 (Idle)
		anim.stop()
		sprite.frame = 0
