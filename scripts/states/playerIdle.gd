extends State
class_name PlayerIdle

@export var player: Player
var playerData: PlayerMovementData
var playerSettings: PlayerSettings

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

	player.velocity.x = move_toward(player.velocity.x, 0, playerData.LERP_SPEED)
	player.velocity.z = move_toward(player.velocity.z, 0, playerData.LERP_SPEED)
	
	var input = Input.get_vector("left", "right", "forward", "backward")
	if input:
		transitioned.emit(self, "walk")
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
