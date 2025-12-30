extends CharacterBody2D

@onready var animationplayer=$AnimationPlayer
@onready var sprite2D=$Sprite2D

func _physics_process(delta: float) -> void:
	
	var directionX = Input.get_axis("ui_left","ui_right")
	var directionY = Input.get_axis("ui_up","ui_down")
	
	move_and_slide()

	animations(directionX,directionY)
	
	if directionX ==1:
		sprite2D.flip_h=false
	elif directionX ==-1:
		sprite2D.flip_h=true
		
	
		
func animations (directionX, directionY):
	
	if directionX==0 and directionY==0:
		animationplayer.play("idle_front")
	if directionX ==1:
		animationplayer.play("walk_x")
	elif directionX ==-1:
		animationplayer.play("walk_x")		
	if directionY ==1:
		animationplayer.play("walk_down")
	elif directionY ==-1:
		animationplayer.play("walk_up")
