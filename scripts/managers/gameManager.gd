extends Node

const GAME_DATA_PATH: String = "user://game_data.tres"

# level_progression: {
	# level_name: {
		#complete: bool,
		#best_time: float | null
	#},
#}
var gameData: Resource

func _ready() -> void:
	gameData = load_game_data() if not load_game_data() == null else SaveData.new()


func get_current_level_data(level_name: String) -> Dictionary:
	var data = gameData.get("level_progression")
	for key in data.keys():
		if key == level_name:
			return gameData.level_progression[key]
	return {}


func set_current_level_data(level_data: Dictionary) -> void:
	var data = gameData.get("level_progression")
	var level_key = level_data.keys()[0]
	
	# empty dictionary
	if data.keys().size() == 0:
		gameData.level_progression[level_key] = level_data[level_key]
	
	for key in data.keys():
		if key == level_key:
			gameData.level_progression[key] = level_data[level_key]
	
	write_game_data()


func write_game_data() -> void:
	var new_save: SaveData = SaveData.new()
	new_save.level_progression = gameData.level_progression
	ResourceSaver.save(new_save, GAME_DATA_PATH)


func load_game_data() -> Resource:
	if ResourceLoader.exists(GAME_DATA_PATH):
		return ResourceLoader.load(GAME_DATA_PATH).duplicate(true) as SaveData
	
	return null


func create_transition_canvas():
	var canvas = CanvasLayer.new()
	canvas.process_mode = Node.AUTO_TRANSLATE_MODE_ALWAYS
	
	var background = ColorRect.new()
	background.color = Color("#00000000")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(background)
	
	return { "canvas": canvas, "background": background }
