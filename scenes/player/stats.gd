extends CanvasLayer

signal no_stamina()

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var stamina_bar: TextureProgressBar = $StaminaBar
@onready var damage_text: Label = $"../DamageText"
@onready var hp_damage_anim: AnimationPlayer = $"../HPDamageAnim"

var stamina_cost
var attack_cost = 10
var block_cost = 2
var slide_cost = 20
var run_cost = 2
var max_health: int = 100
var old_health = max_health

var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")
var health:
	set(value):
		health = clamp(value, 0, max_health)
		health_bar.value = health
		var difference = health - old_health
		old_health = health
		if difference < 0:
			damage_text.text = str(abs(difference))
			hp_damage_anim.play("damage_received")
		elif difference > 0:
			damage_text.text = str(difference)
			hp_damage_anim.play("health_received")

func _ready() -> void:
	health = max_health
	health_bar.max_value = health
	health_bar.value = health
	
func _process(delta: float) -> void:
	stamina_bar.value = stamina
	if stamina < 100:
		stamina += 10 * delta

func stamina_consumption():
	stamina -= stamina_cost

func _on_timer_timeout() -> void:
	health += 1
