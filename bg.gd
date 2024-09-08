extends ParallaxBackground


var speed: int =  100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scroll_offset.x -= speed * delta 
