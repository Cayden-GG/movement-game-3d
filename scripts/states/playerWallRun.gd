extends State
class_name PlayerWallRun

@export var audioManager: AudioManager
@export var player: Player
@export var head: Node3D

var playerData: PlayerMovementData
var playerSettings: PlayerSettings

var currentWallNormal: Vector3 = Vector3.ZERO
var wallStickForce: float = 5.0  
var playerCameraTilt: float = 20.0
var wallSide: String = "NONE"
var wallRunTimer: float = 0.0

var stepDistance: float = 4.5
var distanceTraveled: float = 0.0

func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings
	wallRunTimer = playerData.MAX_WALL_RUN_TIME
	
	updateWallInfo()

func exit(nextState: State) -> void:
	tiltPlayerCamera(0.0)

func update(delta: float) -> void:
	pass


func physics_update(delta: float) -> void:
	wallRunTimer -= delta
	updateWallInfo()
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if wallSide == "NONE" or wallRunTimer <= 0.0 or not input_dir:
		transitioned.emit(self, "fall")
		return
	
	if player.is_on_floor():
		transitioned.emit(self, "idle")
		return
	
	if Input.is_action_pressed("jump"):
		var outwardForce: float = 30
		var upwardForce: float  = 0.5
		
		var forwardDir = -player.transform.basis.z
		var jumpDir = (currentWallNormal * outwardForce + Vector3.UP * upwardForce + forwardDir * player.velocity.length()).normalized()

		player.velocity = jumpDir * min(player.velocity.length(), playerData.MAX_VELOCITY)
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
	
	var tilt = playerCameraTilt if wallSide == "RIGHT" else -playerCameraTilt
	tiltPlayerCamera(tilt)
	
	movePlayer(delta)
	
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


func movePlayer(delta) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var rawWorldDir = (player.transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	var wallTangent = rawWorldDir.slide(currentWallNormal).normalized()
	
	if input_dir.y != 0:
		player.velocity.x = wallTangent.x * min(player.velocity.length(), playerData.MAX_VELOCITY)
		player.velocity.z = wallTangent.z * min(player.velocity.length(), playerData.MAX_VELOCITY)
	
	player.velocity.y = 0.0
	
	player.velocity += -currentWallNormal * wallStickForce * delta

var tilt_tween: Tween

func tiltPlayerCamera(target_degrees: float, duration: float = 0.25) -> void:
	if tilt_tween and tilt_tween.is_running():
		tilt_tween.kill()
		
	tilt_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tilt_tween.tween_property(head, "rotation:z", deg_to_rad(target_degrees), duration)

func updateWallInfo() -> void:
	wallSide = "NONE"
	currentWallNormal = Vector3.ZERO
	
	for i in player.get_slide_collision_count():
		var collision = player.get_slide_collision(i)
		var normal = collision.get_normal()
		
		if abs(normal.y) < 0.5:
			currentWallNormal = normal
			var local_pos = player.to_local(collision.get_position())
			wallSide = "RIGHT" if local_pos.x > 0 else "LEFT"
			return
