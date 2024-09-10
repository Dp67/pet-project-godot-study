extends Node2D

@onready var day_text = $CanvasLayer/DayLabel
@onready var lightPlayer = $Light/AnimationPlayer
@onready var health_bar: TextureProgressBar = $CanvasLayer/HealthBar
@onready var player: CharacterBody2D = $Player/Player

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var day_count: int 
			
func _ready():
	health_bar.max_value = player.max_health
	health_bar.value = health_bar.max_value
	day_count = 0
	morning_state()

func morning_state() -> void:
	day_count += 1
	day_text.text = "DAY " + str(day_count)
	lightPlayer.play("sunrise")

func evening_state() -> void:
	lightPlayer.play("sunset")
	

func _on_day_night_timeout() -> void:
	if state < 3:
		state += 1
	else: 
		state = 0	
	match state:
		MORNING:
			morning_state()
		EVENING:
			evening_state()

func _on_player_health_chaged(new_health: Variant) -> void:
	health_bar.value = new_health
