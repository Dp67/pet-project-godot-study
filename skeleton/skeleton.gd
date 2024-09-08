extends CharacterBody2D


const SPEED = 100.0
var chase = false
@onready var anim = $AnimatedSprite2D
var alive = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	if alive == true:
		$AnimatedSprite2D.flip_h = direction.x < 0
		if chase == true: 
			velocity.x = direction.x * SPEED
			anim.play("Run")
		else:
			velocity.x = 0
			anim.play("Idle")
		
	move_and_slide()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false


func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y -= 300
		death()

func death() -> void: 
	alive = false
	anim.play("Death")
	await anim.animation_finished
	queue_free()


func _on_hit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if alive == true:
			body.health -= 40
		death()
