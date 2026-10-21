extends State
class_name PlayerGroundPound

@export var player: Player

var playerData: PlayerMovementData
var queuedState: String
var initVel: Vector3
var exitVelocity: float

func enter(prevState: State) -> void:
	playerData = player.playerData
	initVel = Vector3(player.velocity.x, 0.0, player.velocity.z)
	exitVelocity = 0.0
	player.velocity.y -= playerData.GROUND_POUND_VELOCITY

func exit(nextState: State) -> void:
	player.velocity = initVel * playerData.GROUND_POUND_EXIT_BOOST

func update(delta: float) -> void:
	pass

func boostPlayer() -> void:
	if player.velocity.length() < playerData.MAX_VELOCITY:
		player.velocity += Vector3(playerData.SLIDE_BOOST_VELOCITY, 0, playerData.SLIDE_BOOST_VELOCITY) * player.direction

func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, initVel.x / 2, delta * 2)
	player.velocity.z = move_toward(player.velocity.z, initVel.x / 2, delta * 2)
	
	exitVelocity = min(exitVelocity, player.velocity.y)
	
	if player.is_on_floor():
		transitioned.emit(self, "land")
