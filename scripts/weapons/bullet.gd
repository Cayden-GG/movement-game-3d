extends Weapon
class_name Bullet

var velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	global_position += velocity * delta


func _on_body_entered(body: Node3D) -> void:
	queue_free()
