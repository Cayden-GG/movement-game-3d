extends Camera3D


@export var player: Player
@export var scaleSpeed: float = 6.0
@export var increaseLimit: float = 18.0 

var playerData: PlayerMovementData

func _ready() -> void:
	playerData = player.playerData
	fov = playerData.BASE_FOV


func _physics_process(delta: float) -> void:
	scaleFOV(delta)


func scaleFOV(delta: float, new_fov: float = 0.0) -> void:
	var velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var target = new_fov if not new_fov == 0.0 else playerData.BASE_FOV + min(velocity.length() / 1.5, increaseLimit) 
	fov = lerp(fov, target, scaleSpeed * delta)
