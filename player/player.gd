extends CharacterBody2D

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE,
	DAMAGE,
	DEATH
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var stats: CanvasLayer = $Stats

var gold: int = 0 
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false
var player_pos
var damage_basic = 10
var damage_multipler = 1
var damage_current
var recovery = false

func _ready() -> void:
	Singnals.connect("enemy_attack", Callable(self, "_on_damage_received"))

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		DAMAGE:
			damage_state()
		SLIDE:
			slide_state()	
		DEATH:
			death_state()
		
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.y > 0: 
		animPlayer.play("Fall")	
		
	damage_current = damage_basic * damage_multipler
		
	move_and_slide()
	
	player_pos = self.position
	Singnals.emit_signal("player_position_update", player_pos)

func move_state() -> void:
	var direction := Input.get_axis("left", "right")
	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			stats.stamina_cost = stats.run_cost
			if run_speed == 1:
				animPlayer.play("Walk")
			else:
				stats.stamina -= stats.stamina_cost
				animPlayer.play("Run")	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
			
	if Input.is_action_pressed("run") and (stats.stamina_cost < stats.stamina and recovery != true):
		run_speed = 2	
	else: 
		run_speed = 1	
		
	if Input.is_action_pressed("block"):
		if not recovery:
			if velocity.x == 0:
				stats.stamina_cost = stats.block_cost
				if stats.stamina_cost < stats.stamina:
					state = BLOCK
			else: 
				stats.stamina_cost = stats.slide_cost
				if stats.stamina_cost < stats.stamina:
					state = SLIDE
	
	if Input.is_action_just_pressed("attack"):
		if not recovery:
			stats.stamina_cost = stats.attack_cost
			if attack_cooldown == false and stats.stamina_cost < stats.stamina:
				state = ATTACK
				
func block_state() -> void:
	stats.stamina -= stats.block_cost
	velocity.x = 0
	animPlayer.play("Block")
	if Input.is_action_just_released("block") or recovery == true:
		state = MOVE
		
func slide_state() -> void:
	stats.stamina_cost = stats.slide_cost
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state() -> void: 
	stats.stamina_cost = stats.attack_cost
	damage_multipler = 1
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina_cost < stats.stamina:
		state = ATTACK2
	velocity.x = move_toward(velocity.x, 0, SPEED)
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE	
	
func attack2_state() -> void: 
	damage_multipler = 1.2
	if Input.is_action_just_pressed("attack") and combo == true and stats.stamina_cost < stats.stamina:
		state = ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack3_state() -> void: 
	stats.stamina_cost = stats.attack_cost
	damage_multipler = 2
	animPlayer.play("Attack3")
	await animPlayer.animation_finished
	state = MOVE		
	
func combo1() -> void:
	combo = true
	await animPlayer.animation_finished
	combo = false
	
func attack_freeze() -> void:
	attack_cooldown	= true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown	= false
	
func damage_state() -> void:
	velocity.x = 0
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = MOVE
	
func death_state() -> void:
	velocity.x = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	get_tree().change_scene_to_file.bind("res://scenes/menu/menu.tscn").call_deferred()

func _on_damage_received(enemy_damage) -> void:
	if state == BLOCK:
		enemy_damage /= 2
	elif state == SLIDE:
		enemy_damage = 0
	else:
		state = DAMAGE	
	stats.health -= enemy_damage
	if stats.health <= 0:
		stats.health = 0
		state = DEATH

func _on_hit_box_area_entered(area: Area2D) -> void:
	Singnals.emit_signal("player_attack", damage_current)

func _on_stats_no_stamina() -> void:
	recovery = true
	await get_tree().create_timer(4).timeout
	recovery = false
