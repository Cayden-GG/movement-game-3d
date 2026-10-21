extends MeshInstance3D

@export var player: Player

var playerData: PlayerMovementData

func _ready() -> void:
	playerData = player.playerData

func _physics_process(_delta: float) -> void:
	var wightedVelocity = Vector3(player.velocity.x, player.velocity.y / 1.5, player.velocity.z).length()
	var effectStrength = min(wightedVelocity, playerData.MAX_VELOCITY) / playerData.MAX_VELOCITY
	applyEffect(effectStrength / 1.8)


func applyEffect(value: float) -> void:
	var mat = mesh.material as ShaderMaterial
	mat.set_shader_parameter('effect_power', value)
