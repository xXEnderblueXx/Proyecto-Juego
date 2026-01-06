extends ParallaxBackground

@export var velocidad_paralax: float=18.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= velocidad_paralax * delta
