extends CharacterBody2D

enum {
	IDLE,
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
var health: int = 100
var gold: int = 0 
var state = MOVE
var run_speed = 1
var combo = false
var attack_cooldown = false

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
		SLIDE:
			slide_state()				
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if velocity.y > 0: 
		animPlayer.play("Fall")	
		
	if health <= 0:
		health = 0
		animPlayer.play("Death")
		await animPlayer.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")
		
		
	move_and_slide()

func move_state() -> void:
	var direction := Input.get_axis("left", "right")
	anim.flip_h = direction < 0
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("Walk")
			else:
				animPlayer.play("Run")	
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
		
	if Input.is_action_pressed("run"):
		run_speed = 2	
	else: 
		run_speed = 1	
		
	if Input.is_action_pressed("block"):
		if velocity.x == 0:
			state = BLOCK
		else: 
			state = SLIDE
	
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK
				
func block_state() -> void:
	velocity.x = 0
	animPlayer.play("Block")
	if Input.is_action_just_released("block"):
		state = MOVE
		
func slide_state() -> void:
	animPlayer.play("Slide")
	await animPlayer.animation_finished
	state = MOVE
	
func attack_state() -> void: 
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	attack_freeze()
	state = MOVE	
	
func attack2_state() -> void: 
	if Input.is_action_just_pressed("attack") and combo == true:
		state = ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = MOVE
	
func attack3_state() -> void: 
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
