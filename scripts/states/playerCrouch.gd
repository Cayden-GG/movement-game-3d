extends State
class_name PlayerCrouch

@onready var colliderBody: CollisionShape3D = $"../../CollisionShape3D"
@onready var meshBody: MeshInstance3D = $"../../body"
@onready var ceilingCheck: RayCast3D = $"../../ceilingCheckRay"
@onready var head: Node3D = $"../../head"

@export var audioManager: AudioManager
@export var player: Player

var playerData: PlayerMovementData
var playerSettings: PlayerSettings
var stepDistance: float = 5.0
var distanceTraveled: float = 0.0

var is_preparing_jump: bool = false

func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings
	player.floor_snap_length = 1


func exit(nextState: State) -> void:
	while (not changePlayerHeight(get_physics_process_delta_time(), "up")):
		await get_tree().physics_frame
	player.floor_snap_length = 0.1


func update(delta: float) -> void:
	pass


func changePlayerHeight(delta: float, direction: String = "down") -> bool:
	var targetHeight: float
	var heightChangeSpeed: float = 5.0
	if direction == "down":
		targetHeight = playerData.CROUCH_PLAYER_HEIGHT
	else:
		targetHeight = player.playerData.BASE_PLAYER_HEIGHT
		heightChangeSpeed *= 1.5
	
	colliderBody.shape.height = lerp(colliderBody.shape.height, targetHeight, heightChangeSpeed * delta)
	meshBody.mesh.height = lerp(colliderBody.shape.height, targetHeight, heightChangeSpeed * delta)

	head.position.y = lerp(head.position.y, targetHeight - player.playerData.CAMERA_EYE_LEVEL, heightChangeSpeed * delta)
	
	if targetHeight - colliderBody.shape.height <= 0.1:
		return true
	return false


func movePlayer(delta: float, moveSpeed: float = playerData.CROUCH_SPEED) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	player.direction = lerp(player.direction, (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), playerData.LERP_SPEED * delta)
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * moveSpeed, playerData.CROUCH_ACCEL * delta)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * moveSpeed, playerData.CROUCH_ACCEL * delta)
	else: 
		player.velocity.x = move_toward(player.velocity.x, 0, playerData.LERP_SPEED)
		player.velocity.y = move_toward(player.velocity.y, 0, playerData.LERP_SPEED)


func physics_update(delta: float) -> void:
	player.apply_floor_snap()
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
	
	if not ceilingCheck.is_colliding():
		if Input.is_action_pressed("jump") and player.is_on_floor():
			transitioned.emit(self, "jump")
			return
		
		if Input.is_action_pressed("sprint"):
			transitioned.emit(self, "sprint")
			return
	
	var isCrouching: bool = true
	if not playerSettings.toggleCrouch:
		isCrouching = Input.is_action_pressed("crouch")
	else:
		if Input.is_action_just_pressed("crouch"):
			isCrouching = false
	
	if not isCrouching and ceilingCheck.is_colliding():
		isCrouching = true
	
	# update audio
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var speed = horizontal_velocity.length()
	
	if speed > 0.1:
		distanceTraveled += speed * delta
		
		if distanceTraveled >= stepDistance:
			distanceTraveled -= stepDistance
			audioManager.updateAudio("walk")
	else:
		distanceTraveled = 0.0
	
	if isCrouching: 
		changePlayerHeight(delta, "down")
		movePlayer(delta)
	else:
		changePlayerHeight(delta, "up")
		movePlayer(delta, playerData.WALK_SPEED)
		
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		if input_dir != Vector2.ZERO:
			if Input.is_action_pressed("sprint"):
				transitioned.emit(self, "sprint")
				return
			else:
				transitioned.emit(self, "walk")
				return
		else: 
			transitioned.emit(self, "idle")
