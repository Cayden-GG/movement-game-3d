extends State
class_name PlayerSlide

@onready var colliderBody: CollisionShape3D = $"../../CollisionShape3D"
@onready var meshBody: MeshInstance3D = $"../../body"
@onready var ceilingCheck: RayCast3D = $"../../ceilingCheckRay"
@onready var head: Node3D = $"../../head"

@export var player: Player

var playerData: PlayerMovementData
var playerSettings: PlayerSettings

var currentSlideVelocity: Vector3 = Vector3.ZERO
var slopeGravityMult: float = 25.0     
var uphillFrictionMult: float = 2.0     
var steerAccel: float = 8.0


func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings
	player.floor_snap_length = 1
	
	if player.velocity.length() < playerData.MAX_VELOCITY:
		player.velocity += Vector3(playerData.SLIDE_BOOST_VELOCITY, 0, playerData.SLIDE_BOOST_VELOCITY) * player.direction
	
	currentSlideVelocity = player.velocity


func exit(nextState: State) -> void:
	if nextState.name == "crouch":
		return
	while (changePlayerHeight(get_physics_process_delta_time(), "up") == false):
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

func movePlayer(delta: float) -> void:
	var floorNormal = player.get_floor_normal()
	var floorAngle = player.get_floor_angle()
	
	var downhillDir = Vector3.DOWN.slide(floorNormal)
	
	if floorAngle > deg_to_rad(1.0):
		downhillDir = downhillDir.normalized()
		
		var currentDir = currentSlideVelocity.normalized()
		var downhillAlignment = currentDir.dot(downhillDir)
		
		if downhillAlignment > 0.0:
			# DOWNHILL
			var slopeAccel = sin(floorAngle) * slopeGravityMult
			currentSlideVelocity += downhillDir * slopeAccel * delta
		else:
			# UPHILL
			var slopeDrag = sin(floorAngle) * slopeGravityMult * uphillFrictionMult
			currentSlideVelocity = currentSlideVelocity.move_toward(Vector3.ZERO, (playerData.SLIDE_FRICTION + slopeDrag) * delta)
	else:
		# FLATGROUND
		currentSlideVelocity = currentSlideVelocity.move_toward(Vector3.ZERO, playerData.SLIDE_FRICTION * delta)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	if input_dir != Vector2.ZERO:
		var rawSteer = (player.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var floorSteer = rawSteer.slide(floorNormal).normalized()
		
		var targetVel = floorSteer * currentSlideVelocity.length()
		
		currentSlideVelocity = currentSlideVelocity.lerp(targetVel, steerAccel * delta) 
	
	player.velocity = currentSlideVelocity


func physics_update(delta: float) -> void:
	player.apply_floor_snap()
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return
	
	if not ceilingCheck.is_colliding():
		if Input.is_action_just_pressed("jump") and player.is_on_floor():
			transitioned.emit(self, "jump")
			return
		if Input.is_action_just_pressed("sprint") and not ceilingCheck.is_colliding():
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
	
	if player.velocity.length() <= playerData.CROUCH_SPEED and isCrouching:
		transitioned.emit(self, "crouch")
		return
	
	if isCrouching:
		changePlayerHeight(delta, "down")
		movePlayer(delta)
	else:
		changePlayerHeight(delta, "up")
		movePlayer(delta)
		
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
			return
