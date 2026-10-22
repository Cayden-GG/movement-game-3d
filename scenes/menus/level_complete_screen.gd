extends Control

@onready var level_time_label: Label = $Right/Score/currentTime/levelTime
@onready var best_time_label: Label = $Right/bestTime
@onready var new_high_score: Label = $Right/Score/newHighScore
@onready var next: Button = $Right/buttons/Next
@onready var main_menu: Button = $Right/buttons/mainMenu

var best_time: float
var current_time: float

func _ready() -> void:
	level_time_label.text = "%f" % current_time
	best_time_label.text = "%f" % best_time
	
	if current_time < best_time:
		new_high_score.visible = true
	
	next.button_up.connect(_on_next_pressed)
	main_menu.button_up.connect(_on_main_menu_pressed)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _on_next_pressed() -> void:
	pass

func _on_main_menu_pressed() -> void:
	pass
