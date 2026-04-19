extends Sprite2D

@onready var anim_player = $AnimationPlayer
@export var jojos_chance: float = 0.2
var is_game_paused: bool = false
var is_dancing: bool = false # Nueva variable para dar prioridad al ritmo

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)
	decidir_siguiente_animacion()

# --- NUEVA FUNCIÓN: BAILAR AL RITMO ---
func bailar_direccion(nombre_anim: String) -> void:
	if is_game_paused: return
	
	is_dancing = true
	
	if anim_player.has_animation(nombre_anim):
		anim_player.stop() # Forzamos reinicio para marcar notas seguidas
		anim_player.play(nombre_anim)
		anim_player.seek(0.0, true)
		
		anim_player.speed_scale = 1.5
	else:
		push_error("EL CAPATAZ NO TIENE LA ANIMACIÓN: ", nombre_anim)
func _on_animation_finished(anim_name: String) -> void:
	if is_game_paused: return

	# Lista de tus animaciones rítmicas
	var animaciones_ritmo = ["left", "right", "jump", "crouch", "interact","jojos"]

	# Si terminó un paso de baile, salimos del estado de baile
	if anim_name in animaciones_ritmo:
		is_dancing = false
		decidir_siguiente_animacion()
	
	# Si estábamos en reposo o haciendo la pose
	elif not is_dancing:
		if anim_name == "idle" or anim_name == "jojos":
			decidir_siguiente_animacion()

func decidir_siguiente_animacion() -> void:
	if is_dancing: return 
	
	if randf() < jojos_chance:
		anim_player.play("jojos")
	else:
		anim_player.play("idle")
