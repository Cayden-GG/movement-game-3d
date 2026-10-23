extends Control

@export var menu_btns: VBoxContainer
@export var level_container: GridContainer

var level_data: Dictionary

func _ready() -> void:
	var data = GameManager.load_game_data()
	level_data = data.level_progression
	load_levels()

func load_levels() -> void:
	var previous_unlocked_level: int = 1
	for key in level_data.keys():
		var cur_level = int(str(key).split("_")[1]) # split name and number "level_1"
		if level_data[key].complete:
			previous_unlocked_level = cur_level
		
		var level := { 
			"level_name": key, 
			"is_complete": level_data[key].complete,
			"is_next_unlocked": true if level_data[key].complete == false and cur_level - previous_unlocked_level == 1 else false,
			"best_time": level_data[key].best_time
		}
		create_level_item(level)


func create_level_item(level: Dictionary) -> void:
	var button = Button.new()
	button.custom_minimum_size = Vector2(125, 125)
	level_container.add_child(button)
	var container = VBoxContainer.new()
	button.add_child(container)
	
	var l_name = Label.new()
	l_name.text = level["level_name"]
	container.add_child(l_name)
	
	if level["is_complete"]:
		# complete
		var l_best_time = Label.new()
		l_best_time.text = "%f" % level["best_time"]
		container.add_child(l_best_time)
	else:
		# uncomplete
		var l_level_locked = Label.new()
		if level["is_next_unlocked"]:
			# next level
			l_level_locked.text = "Next Level"
		else:
			# not next level
			l_level_locked.text = "Locked"
			button.disabled = true
		container.add_child(l_level_locked)
	
	# connect button
	var level_scene_path = "res://scenes/levels/%s.tscn" % level["level_name"].to_lower()
	button.pressed.connect(func():
		await SceneTransition.change_scene(level_scene_path)
	)


func _on_play_btn_pressed() -> void:
	menu_btns.visible = false
	level_container.visible = true



func _on_exit_btn_pressed() -> void:
	get_tree().quit()
