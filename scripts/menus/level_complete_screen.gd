extends Control

@onready var level_time_label: Label = $Right/Score/currentTime/levelTime
@onready var best_time_label: Label = $Right/bestTime
@onready var new_high_score: Label = $Right/Score/newHighScore
@onready var next: Button = $Right/buttons/Next
@onready var main_menu: Button = $Right/buttons/mainMenu

var best_time: float
var current_time: float
var current_level: int

func _ready() -> void:
	level_time_label.text = "%f" % current_time
	
	if current_time < best_time or best_time == null:
		best_time = current_time
		new_high_score.visible = true
	
	best_time_label.text = "Best Time: %f" % best_time if best_time else current_time
	
	next.pressed.connect(_on_next_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _on_next_pressed() -> void:
	var next_level = "Level_%f" % (current_level + 1)
	var file_path = "res://scenes/levels/%s.tscn" % next_level
	
	if FileAccess.file_exists(file_path):
		SceneTransition.change_scene(file_path)
	else:
		_on_main_menu_pressed()

func _on_main_menu_pressed() -> void:
	SceneTransition.change_scene("res://scenes/menus/main_menu.tscn")
