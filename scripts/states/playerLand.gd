extends State
class_name PlayerLand

@onready var jump_buffer: Timer = $"../../jumpBuffer"
@onready var stateManager: StateMachine = $".."

@export var audioManager: AudioManager
@export var player: Player

var playerData: PlayerMovementData
var playerSettings: PlayerSettings

var land_timer: float = 0.0
var max_vel: float
var exitVelocity: float

func enter(prevState: State) -> void:
	playerData = player.playerData
	playerSettings = player.playerSettings
	land_timer = playerData.LAND_DURATION
	jump_buffer.resetTimer()
	max_vel = 0.0
	exitVelocity = prevState.exitVelocity or 0

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func lastMovingState() -> String:
	var history = stateManager.stateHistory
	for state in history:
		if state in ["walk", "sprint"]:
			return state
	return "walk"

func physics_update(delta: float) -> void:
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return
	
	if Input.is_action_pressed("jump"):
		transitioned.emit(self, "jump")
		return
	
	if Input.is_action_pressed("crouch") and not playerSettings.toggleCrouch:
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			transitioned.emit(self, "slide")
		else:
			transitioned.emit(self, "crouch")
	
	if Input.is_action_just_pressed("crouch") and playerSettings.toggleCrouch or Input.is_action_pressed("crouch"):
		if player.velocity.length() >= playerData.CROUCH_TRANSITION_VEL:
			transitioned.emit(self, "slide")
		else:
			transitioned.emit(self, "crouch")
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var current_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	max_vel = max(current_vel.length(), max_vel)
	
	if input_dir != Vector2.ZERO:
		var target_dir = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var target_speed = max_vel * playerData.LAND_MOVE_MULT
		var target_velocity = target_dir * target_speed
		
		var new_vel = current_vel.move_toward(target_velocity, playerData.WALK_SPEED * 8.0 * delta)
		player.velocity.x = new_vel.x
		player.velocity.z = new_vel.z
	else:
		var new_vel = current_vel.move_toward(Vector3.ZERO, playerData.WALK_SPEED * 10.0 * delta)
		
		player.velocity.x = new_vel.x
		player.velocity.z = new_vel.z
		
	audioManager.updateAudio("land", exitVelocity)

	land_timer -= delta
	if land_timer <= 0 or max_vel < playerData.STAGGER_VELOCITY:
		if input_dir != Vector2.ZERO:
			var nextState = lastMovingState()
			
			if Input.is_action_pressed("sprint"):
				transitioned.emit(self, "sprint")
			else:
				transitioned.emit(self, nextState)
		else:
			transitioned.emit(self, "idle")
		return
		
