extends Node3D

@export var player: Player

@export var frequncy: float = 1.0 
@export var amplitude: float = 0.04
@export var reset_time: float = 4.0

var num: float = 0.1
var switch = true
var time: float = 0.0
var cameraPitch: float = 0.0

var cameraPos_Y: float

var playerSettings: PlayerSettings

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	playerSettings = player.playerSettings
	cameraPos_Y = player.playerData.BASE_PLAYER_HEIGHT - player.playerData.CAMERA_EYE_LEVEL
	position.y = cameraPos_Y

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.rotate_y(deg_to_rad(-event.relative.x * playerSettings.MOUSE_SENS))
		rotate_x(deg_to_rad(-event.relative.y * playerSettings.MOUSE_SENS))
		rotation.x = clamp(rotation.x, deg_to_rad(-89), deg_to_rad(89))

func handleControllerLook(delta: float) -> void:
	var lookDir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	
	if lookDir.length_squared() > 0.0:
		var yaw = lookDir.x * playerSettings.CONTROLLER_SENS * delta
		var pitch = lookDir.y * playerSettings.CONTROLLER_SENS * delta
		apply_look(yaw, pitch)

func apply_look(yaw: float, pitch: float) -> void:
	player.rotate_y(-yaw)
	
	cameraPitch = clamp(cameraPitch - pitch, deg_to_rad(-89.0), deg_to_rad(89.0))
	rotation.x = cameraPitch

func _physics_process(delta: float) -> void:
	handleControllerLook(delta)
	
	time += delta * player.velocity.length() 
	var target_pos: Vector3
	
	if (float(player.is_on_floor()) or float(player.is_on_wall())) and player.velocity.length() > 0.1:
		target_pos = headBob(time)
	else:
		target_pos = Vector3(0, cameraPos_Y, 0)
		time = move_toward(time, 0.0, delta * 2.0)
	
	transform.origin = transform.origin.lerp(target_pos, reset_time * delta)


func headBob(time: float) -> Vector3:
	var postition = Vector3.ZERO
	postition.y = cameraPos_Y + sin(time * frequncy) * amplitude
	postition.x = cos(time * frequncy / 2) * amplitude
	
	return postition
