extends CharacterBody2D

@onready var mushroomAnimPlayer = $MushroomAnimPlayer
@onready var sprite = $AnimatedSprite2D

enum {
	IDLE,
	CHASE,
	ATTACK,
	TAKE_HIT,
	DEATH
}

var state: int = 0: 
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			CHASE:
				pass
			ATTACK:
				attack_state()
			TAKE_HIT:
				pass
			DEATH:
				pass
				
var player_pos	
var direction	
var damage = 20		
				
func _ready() -> void:
	Singnals.connect("player_position_update", Callable (self, "_on_player_position_update"))				

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if state == CHASE:
		chase_state()
			

	move_and_slide()

@warning_ignore("shadowed_variable")
func _on_player_position_update(player_pos):
	self.player_pos = player_pos

func _on_attack_range_body_entered(_body: Node2D) -> void:
	state = ATTACK
	
func idle_state() -> void:
	mushroomAnimPlayer.play("Idle")
	await get_tree().create_timer(1).timeout
	$AttackDirection/AttackRange/CollisionShape2D.disabled = false
	state = CHASE
	
func attack_state() -> void:
	mushroomAnimPlayer.play("Attack")
	await mushroomAnimPlayer.animation_finished
	$AttackDirection/AttackRange/CollisionShape2D.disabled = true
	state = IDLE	
	
func chase_state() -> void:
	direction = (player_pos - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else: 	
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0


func _on_hit_box_area_entered(area: Area2D) -> void:
	Singnals.emit_signal("enemy_attack", damage)
