extends Sprite2D

# Referencia interna al AnimationPlayer
@onready var anim_player = $AnimationPlayer

# Probabilidad de que salga la animación especial (0.0 a 1.0)
# 0.2 significa 20% de probabilidad de "jojos", 80% de "idle"
@export var jojos_chance: float = 0.2

var is_game_paused: bool = false

func _ready() -> void:
	# Conectamos la señal para saber cuándo termina una animación
	# Esto garantiza la "consistencia": nunca cortaremos una animación a la mitad
	anim_player.animation_finished.connect(_on_animation_finished)
	
	# Iniciamos con idle por defecto
	play_gameplay_loop()

func _on_animation_finished(anim_name: String) -> void:
	# Si estamos pausados, no hacemos nada (se queda en loop de pause o quieto)
	if is_game_paused:
		return

	# Si terminó "idle" o "jojos", decidimos cuál sigue
	if anim_name == "idle" or anim_name == "jojos":
		decidir_siguiente_animacion()

func decidir_siguiente_animacion() -> void:
	# Generamos un número aleatorio entre 0.0 y 1.0
	if randf() < jojos_chance:
		anim_player.play("jojos")
	else:
		anim_player.play("idle")

# --- FUNCIONES PÚBLICAS (Para llamar desde Gameplay.gd) ---

func set_paused_mode(activo: bool) -> void:
	is_game_paused = activo
	
	if is_game_paused:
		anim_player.play("pause")
	else:
		# Al reanudar, forzamos el inicio del ciclo de nuevo
		decidir_siguiente_animacion()

func play_gameplay_loop() -> void:
	is_game_paused = false
	anim_player.play("idle")
