extends Control
class_name MainMenu

@onready var canvas: CanvasLayer = $CanvasLayer
@onready var cursor: TextureRect = $CanvasLayer/Cursor
@onready var toggleCrouch: CheckButton = $CanvasLayer/VBoxContainer/toggleCrouch
@onready var toggleSprint: CheckButton = $CanvasLayer/VBoxContainer/toggleSprint

@export var playerSettings: Resource
@export var default_focused_control: Control 

var virtual_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	toggleCrouch.button_pressed = playerSettings.toggleCrouch
	toggleSprint.button_pressed = playerSettings.toggleSprint
	
	await get_tree().process_frame
	initializeCursorPosition()

func initializeCursorPosition() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	
	if is_instance_valid(default_focused_control):
		virtual_pos = default_focused_control.global_position + (default_focused_control.size / 2.0)
	else:
		virtual_pos = viewport_size / 2.0
	
	updateVirtualCursor(virtual_pos)

func _process(delta: float) -> void:
	handleControllerCursor(delta)

func _on_toggle_slide_toggled(toggled_on: bool) -> void:
	playerSettings.toggleCrouch = toggled_on

func _on_toggle_sprint_toggled(toggled_on: bool) -> void:
	playerSettings.toggleSprint = toggled_on

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if get_tree().paused else Input.MOUSE_MODE_VISIBLE
		canvas.visible = !get_tree().paused
		get_tree().paused = !get_tree().paused
	
	if event.is_action_pressed("ui_accept"):
		parseVirtualClick(true)
	elif event.is_action_released("ui_accept"):
		parseVirtualClick(false)

func handleControllerCursor(delta: float) -> void: 
	var lookDir = Input.get_vector("left", "right", "forward", "backward")
	
	if lookDir.length_squared() > 0.0:
		var viewport_size = get_viewport().get_visible_rect().size
		
		# Move virtual position
		virtual_pos += lookDir * 1000 * delta
		virtual_pos = virtual_pos.clamp(Vector2.ZERO, viewport_size)
		
		updateVirtualCursor(virtual_pos)

func updateVirtualCursor(new_pos: Vector2) -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	cursor.position = new_pos
	
	var motion_event = InputEventMouseMotion.new()
	motion_event.position = new_pos
	motion_event.global_position = new_pos
	
	updateHoverFocus()
	get_viewport().push_input(motion_event)

func updateHoverFocus() -> void:
	var hovered = get_viewport().gui_get_hovered_control()
	
	if hovered and hovered.focus_mode != Control.FOCUS_NONE:
		if not hovered.has_focus():
			hovered.grab_focus()


func parseVirtualClick(is_pressed: bool) -> void:
	var click_event = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = is_pressed
	click_event.position = virtual_pos
	click_event.global_position = virtual_pos
	#Input.parse_input_event(click_event)
	get_viewport().push_input(click_event)
