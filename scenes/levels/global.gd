extends Node

# --- PERSISTENCIA DE MUNDO ---
var last_player_pos = Vector2.ZERO
var target_spawn_id = "" # Para saber en qué puerta aparecer

# --- ESTADO DE MISIONES ---
var mascara_completada = false
var traje_completado = false

# --- INVENTARIO ---
var inventory = [] # Guardaremos: ["Papel Mache", "Pintura", "Arepa"]

# --- REGISTRO DE DIÁLOGOS ---
var npc_interactions = {
	"Artesano": 0, # 0: No conoce, 1: Misión activa, 2: Finalizado
	"Anciana": 0
}
