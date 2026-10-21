extends Area3D
class_name BoostGate

@export var boost_increase: float = 3
@export var max_boost: float = 40
@export var boost_duration: float = 1.5

var boost_timer: float = 0.0
var player: Player
var boost: bool = false

func _ready() -> void:
	boost_timer = boost_duration

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		boost = true

func _physics_process(delta: float) -> void:
	if not boost or not player:
		return
	
	if boost_timer >= 0:
		var target_vel = Vector3(boost_increase, 0, boost_increase) * player.velocity.normalized()
		target_vel = target_vel * 2.5 if player.is_on_floor() else target_vel
		
		if (player.velocity + target_vel).length() < max_boost:
			player.velocity += target_vel
		boost_timer -= delta
	else:
		boost = false
		boost_timer = boost_duration
