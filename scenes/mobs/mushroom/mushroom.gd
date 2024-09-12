extends CharacterBody2D

@onready var mushroomAnimPlayer = $MushroomAnimPlayer
@onready var sprite = $AnimatedSprite2D

enum {
	IDLE,
	CHASE,
	ATTACK,
	TAKE_HIT,
	RECOVER,
	DEATH
}

var state: int = 0: 
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			TAKE_HIT:
				take_hit_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()
				
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
	state = CHASE
	
func attack_state() -> void:
	mushroomAnimPlayer.play("Attack")
	await mushroomAnimPlayer.animation_finished
	state = RECOVER	
	
func chase_state() -> void:
	direction = (player_pos - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else: 	
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0
		
func take_hit_state() -> void:
	mushroomAnimPlayer.play("Take Hit")
	await mushroomAnimPlayer.animation_finished
	state = RECOVER

func death_state() -> void: 
	mushroomAnimPlayer.play("Death")
	await mushroomAnimPlayer.animation_finished
	queue_free()
	
func recover_state() -> void: 
	mushroomAnimPlayer.play("Recover")
	await mushroomAnimPlayer.animation_finished
	state = IDLE
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	Singnals.emit_signal("enemy_attack", damage)


func _on_mob_health_damage_received() -> void:
	state = IDLE
	state = TAKE_HIT

func _on_mob_health_no_health() -> void:
	state = DEATH
