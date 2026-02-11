extends Sprite2D

@onready var anim_player = $AnimationPlayer
@export var jojos_chance: float = 0.2
var is_game_paused: bool = false
var is_dancing: bool = false # Nueva variable para dar prioridad al ritmo

func _ready() -> void:
	anim_player.animation_finished.connect(_on_animation_finished)
	play_gameplay_loop()

# --- NUEVA FUNCIÓN: BAILAR AL RITMO ---
func bailar_direccion(direccion: String) -> void:
	# Si el juego está pausado, ignoramos las notas
	if is_game_paused: return
	
	# Detenemos el loop de idle para priorizar el paso de baile
	is_dancing = true
	
	# direccion vendrá como "arriba", "abajo", etc.
	var nombre_anim = "baile_" + direccion
	if anim_player.has_animation(nombre_anim):
		anim_player.play(nombre_anim)

func _on_animation_finished(anim_name: String) -> void:
	if is_game_paused: return

	# Si terminó una animación de baile, volvemos al estado base
	if anim_name.begins_with("baile_"):
		is_dancing = false
		decidir_siguiente_animacion()
	
	# Solo si no estamos bailando notas, seguimos con el ciclo idle/jojos
	elif not is_dancing:
		if anim_name == "idle" or anim_name == "jojos":
			decidir_siguiente_animacion()

func decidir_siguiente_animacion() -> void:
	if is_dancing: return # No interrumpir el baile rítmico
	
	if randf() < jojos_chance:
		anim_player.play("jojos")
	else:
		anim_player.play("idle")
