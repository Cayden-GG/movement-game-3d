extends State
class_name PlayerRun

@export var audioManager: AudioManager
@export var player: Player
@export var head: Node3D

var playerData: PlayerMovementData
var playerSettings: PlayerSettings
var stepDistance: float = 4.2
var distanceTraveled: float = 0.0

func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
	
	if Input.is_action_pressed("sprint") and not playerSettings.toggleSprint:
		transitioned.emit(self, "sprint")
		return
	if Input.is_action_just_pressed("sprint") and playerSettings.toggleSprint:
		transitioned.emit(self, "sprint")
		return
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# update movement
	player.direction = lerp(player.direction, (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), playerData.LERP_SPEED * delta)
	if player.direction:
		player.velocity.x = lerp(player.velocity.x, player.direction.x * playerData.WALK_SPEED, playerData.WALK_ACCEL * delta)
		player.velocity.z = lerp(player.velocity.z, player.direction.z * playerData.WALK_SPEED, playerData.WALK_ACCEL * delta)
	else: 
		player.velocity.x = move_toward(player.velocity.x, 0, playerData.LERP_SPEED)
		player.velocity.y = move_toward(player.velocity.y, 0, playerData.LERP_SPEED)
	
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
	
	if player.velocity.length_squared() < 0.1:
		transitioned.emit(self, "idle")
		return
	
	if Input.is_action_pressed("jump") and player.is_on_floor():
		transitioned.emit(self, "jump")
		return
	
	if Input.is_action_pressed("crouch") and not playerSettings.toggleCrouch:
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			transitioned.emit(self, "slide")
		else:
			transitioned.emit(self, "crouch")
		return
	
	if Input.is_action_just_pressed("crouch") and playerSettings.toggleCrouch:
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			transitioned.emit(self, "slide")
		else:
			transitioned.emit(self, "crouch")
		return
