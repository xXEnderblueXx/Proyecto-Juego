extends PlayerCharacter

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

func _ready() -> void:
	anim_tree.active = true
	if $InteractionRayCast:
		$InteractionRayCast.add_exception(self)
func _process(_delta: float) -> void:
	var current_velocity = velocity 

	if current_velocity.length() == 0:
		state_machine.travel("idle")

		var last_dir = get_last_direction()
		anim_tree.set("parameters/Idle/blend_position", last_dir)

	else:
		state_machine.travel("walk")

		var move_dir = current_velocity.normalized()
		anim_tree.set("parameters/walk/blend_position", move_dir)
		anim_tree.set("parameters/idle/blend_position", move_dir)

func _input(event: InputEvent) -> void:
	# Chivato 1: Nos dice si el teclado funciona
	if event is InputEventKey and event.pressed:
			print("Tecla presionada: ", event.as_text()) 

	if event.is_action_pressed("interact"):
			print("Accion de interact detecta en gdscript")
			interact()
