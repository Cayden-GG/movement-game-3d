extends State
class_name PlayerJump

@export var player: Player
@export var floorCheck: RayCast3D
@export var ledgeAssist: LedgeAssist
@export var grapple: GrappleManager

var playerData: PlayerMovementData
var prevState: State

func enter(prevState: State) -> void:
	playerData = player.playerData
	player.velocity.y += playerData.JUMP_VELOCITY
	self.prevState = prevState

	if prevState.name in ["slide", "wallRun"]:
		boostPlayer()

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func boostPlayer() -> void:
	if player.velocity.length() < playerData.MAX_VELOCITY:
		player.velocity += Vector3(playerData.SLIDE_BOOST_VELOCITY, 0, playerData.SLIDE_BOOST_VELOCITY) * player.direction.normalized()

func physics_update(delta: float) -> void:
	player.velocity.y = move_toward(player.velocity.y, 0, playerData.GRAVITY * delta)
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if input_dir and player.is_on_wall():
		var wall_normal = player.get_slide_collision(0).get_normal()
		var angle = rad_to_deg(player.direction.angle_to(wall_normal))
		if angle < 135 and player.velocity.length() > playerData.MIN_WALL_RUN_VELOCITY:
			await get_tree().create_timer(0.13).timeout
			transitioned.emit(self, "wallRun")
	
	# ledge assist
	if ledgeAssist.checkLedgeAssist():
		transitioned.emit(self, prevState.name)
		return
	
	var current_vel = Vector3(player.velocity.x, 0, player.velocity.z)
	player.direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target_velocity = player.direction * max(current_vel.length(), playerData.FALL_SPEED)

	var new_vel = current_vel.lerp(target_velocity, playerData.JUMP_AIR_CONTROL * delta)

	player.velocity.x = new_vel.x
	player.velocity.z = new_vel.z
	
	# ground pound
	if Input.is_action_pressed("crouch") and not floorCheck.is_colliding() and not grapple.launched:
		transitioned.emit(self, "groundPound")
		return 
	
	if player.velocity.y <= 0.0:
		transitioned.emit(self, "fall")
