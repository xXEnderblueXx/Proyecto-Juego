extends Node2D

var type = 0
var hit_time = 0.0
var is_dragging = false

var textures = [
	preload("res://assets/art/sprites/leftnote.png"),
	preload("res://assets/art/sprites/downnote.png"),
	preload("res://assets/art/sprites/upnote.png"),
	preload("res://assets/art/sprites/rightnote.png"),
	preload("res://assets/art/sprites/cruznote.png")
]

func _ready():
	# Escala fija al nacer (Corrige el error visual en Gameplay)
	$Sprite2D.scale = Vector2(0.045, 0.045)

func setup(p_type, _p_speed, p_hit_time):
	type = p_type
	hit_time = p_hit_time
	if type >= 0 and type < textures.size():
		$Sprite2D.texture = textures[type]

func _process(_delta):
	if is_dragging:
		position.x = get_global_mouse_position().x

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var editor = get_parent()
		if event.pressed:
			# Detección precisa de 20 píxeles
			var mouse_dist = get_global_mouse_position().distance_to(global_position)
			if mouse_dist < 20: 
				# Evitar mover varias notas a la vez (Bloqueo global)
				if editor.has_meta("is_any_note_dragging") and editor.get_meta("is_any_note_dragging"):
					return
				
				is_dragging = true
				editor.set_meta("is_any_note_dragging", true)
				modulate = Color(1, 1, 0) # Feedback visual: Amarilla
		else:
			if is_dragging:
				is_dragging = false
				editor.set_meta("is_any_note_dragging", false)
				modulate = Color(1, 1, 1) # Color normal
				
				if editor.has_method("notify_note_moved"):
					editor.notify_note_moved(self)
