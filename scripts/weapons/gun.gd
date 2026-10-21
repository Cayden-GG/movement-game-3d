extends Node3D
class_name Gun

@export var camera: Camera3D
@export var bulletScene: PackedScene = load("res://scenes/weapons/bullet.tscn")
@export_range(1.0, 100.0, 1, "prefer_slider") var bulletVelocity: float = 60.0

@export var maxAimDistance: float = 1000.0

@onready var muzzle: Marker3D = $Muzzle

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	var target = getCrosshairTargetPoint()
	var spawnPos = muzzle.global_position if muzzle else global_position
	var dir = (target - spawnPos).normalized()
	
	var bullet = bulletScene.instantiate() as Bullet
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = spawnPos
	
	bullet.look_at(bullet.global_position + dir)
	bullet.velocity = bulletVelocity * dir

func getCrosshairTargetPoint() -> Vector3:
	if not camera:
		return global_position + (-global_transform.basis.z * maxAimDistance)
	
	var spaceState = get_world_3d().direct_space_state
	var rayStart = camera.global_position
	var rayEnd = rayStart + (-camera.global_transform.basis.z * maxAimDistance)
	
	var query = PhysicsRayQueryParameters3D.create(rayStart, rayEnd)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		query.exclude = [player.get_rid()]

	var result = spaceState.intersect_ray(query)

	if not result.is_empty():
		return result.position
	else:
		return rayEnd
