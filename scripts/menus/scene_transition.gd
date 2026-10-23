extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect

func change_scene(new_scene_path: String) -> void:
	if not new_scene_path :
		return
	
	color_rect.color = Color("#00000000")
	color_rect.visible = true
	
	# fade in
	var fade_in = create_tween()
	fade_in.tween_property(color_rect, "color", Color("#000000"), 0.5)
	await fade_in.finished
	
	get_tree().change_scene_to_file(new_scene_path)
	await get_tree().process_frame
	
	# fade out
	var fade_out = create_tween()
	fade_out.tween_property(color_rect, "color", Color("#00000000"), 0.5)
	await fade_out.finished
	
	color_rect.visible = false
	if get_tree().paused:
		get_tree().paused = false
