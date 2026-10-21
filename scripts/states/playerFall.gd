extends State
class_name PlayerFall

@onready var jumpBuffer: Timer = $"../../jumpBuffer"

@export var player: Player
@export var floorCheck: RayCast3D
@export var grapple: GrappleManager
@export var ledgeAssist: LedgeAssist

var playerData: PlayerMovementData
var playerSettings: PlayerSettings
var queuedState: String
var prevState: State

var exitVelocity: float

func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings
	self.prevState = prevState
	queuedState = ""
	exitVelocity = 0.0

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if jumpBuffer.time_left > 0 or grapple.launched:
			grapple.retract()
			transitioned.emit(self, "jump")
			return
	
	player.velocity.y = move_toward(player.velocity.y, -playerData.TERMINAL_VELOCITY, playerData.GRAVITY * playerData.GRAVITY_MULT * delta)
	exitVelocity = min(exitVelocity, player.velocity.y)
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
		# ledge assist
	if ledgeAssist.checkLedgeAssist():
		var newState = queuedState if queuedState != "" else "walk"
		transitioned.emit(self, newState)
		return
	
	if input_dir and player.is_on_wall() and not prevState.name == "wallRun":
		var wall_normal = player.get_slide_collision(0).get_normal()
		var angle = rad_to_deg(player.direction.angle_to(wall_normal))
		if angle < 135 and player.velocity.length() > playerData.MIN_WALL_RUN_VELOCITY:
			await get_tree().create_timer(0.13).timeout
			transitioned.emit(self, "wallRun")
	
	# ground pound
	if Input.is_action_pressed("crouch") and not floorCheck.is_colliding() and not grapple.launched:
		transitioned.emit(self, "groundPound")
		return 
	
	if Input.is_action_pressed("crouch") and not playerSettings.toggleCrouch:
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			queuedState = "slide"
		else:
			queuedState = "crouch"
	
	if Input.is_action_just_pressed("crouch") and playerSettings.toggleCrouch or Input.is_action_pressed("crouch"):
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			queuedState = "slide"
		else:
			queuedState = "crouch"
	
	if player.is_on_floor():
		if queuedState:
			transitioned.emit(self, queuedState)
			return
		else:
			transitioned.emit(self, "land")
			return
	
	if input_dir != Vector2.ZERO:
		var target_dir = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		var current_vel = Vector3(player.velocity.x, 0, player.velocity.z)
		var current_speed = max(current_vel.length(), playerData.FALL_SPEED) # allows for 0 inital velocity air srafe
		var target_velocity = target_dir * current_speed
		var new_vel = current_vel.move_toward(target_velocity, playerData.FALL_AIR_CONTROL * delta)
		
		player.velocity.x = new_vel.x
		player.velocity.z = new_vel.z
