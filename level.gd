extends Node2D

@onready var light = $Light/DirectionalLight2D
@onready var pointLight = $Light/PointLight2D
@onready var pointLight2 = $Light/PointLight2D2
@onready var day_text = $CanvasLayer/DayLabel
@onready var animationPlayer = $CanvasLayer/AnimationPlayer

enum {
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

var state = MORNING
var day_count: int 
			
func _ready():
	light.enabled = true
	day_count = 1
	set_day_text()
	day_text_fade()

func morning_state() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.25, 15)
	tween.tween_property(pointLight, "energy", 0, 15)

func day_state() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.1, 15)

func evening_state() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.5, 15)
	tween.tween_property(pointLight, "energy", 1.5, 15)

func night_state() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", 0.95, 15)

func _on_day_night_timeout() -> void:
	match state:
		MORNING:
			morning_state()
		DAY:
			day_state()
		EVENING:
			evening_state()
		NIGHT:
			night_state()	
			
	if state < 3:
		state += 1
	else: 
		state = MORNING	
		day_count += 1
		set_day_text()
		day_text_fade()
		
func day_text_fade() -> void:
	animationPlayer.play("day_text_fade_in")
	await get_tree().create_timer(2).timeout
	animationPlayer.play("day_text_fade_out")			

func set_day_text() -> void:
	day_text.text = "DAY " + str(day_count)
