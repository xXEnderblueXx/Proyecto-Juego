extends PlayerCharacter

@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

func _ready() -> void:
	anim_tree.active = true

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
			interact()
#extends PlayerCharacter
#
#@onready var animationplayer=$AnimationPlayer
#@onready var sprite2D=$Sprite2D
#
#func _process(_delta: float) -> void:
	#
	#var directionX = Input.get_axis("ui_left","ui_right")
	#var directionY = Input.get_axis("ui_up","ui_down")
	#
	#move_and_slide()
#
	#animations(directionX,directionY)
	#
	#if directionX ==1:
		#sprite2D.flip_h=false
	#elif directionX ==-1:
		#sprite2D.flip_h=true
#
#func animations (directionX, directionY):
	#
	#if directionX==0 and directionY==0:
		#animationplayer.play("idle_front")
	#if directionX ==1:
		#animationplayer.play("walk_x")
	#elif directionX ==-1:
		#animationplayer.play("walk_x")		
	#if directionY ==1:
		#animationplayer.play("walk_down")
	#elif directionY ==-1:
		#animationplayer.play("walk_up")
