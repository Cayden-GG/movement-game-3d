extends Node
class_name LedgeAssist

@export var player: Player
@export var lowerRay: RayCast3D
@export var higherRay: RayCast3D
@export var ledgeCast: ShapeCast3D
@export var ceilingCheckRay: RayCast3D 

@export_range(0.1, 1.0, 0.1, "prefer_slider") var maxLedgeSnapHeight: float = 0.3 
@export_range(0.05, 0.5, 0.05, "prefer_slider") var ledgeClearanceTime: float = 0.1

func _ready() -> void:
	higherRay.position.y = lowerRay.position.y + maxLedgeSnapHeight

func checkLedgeAssist() -> bool:
	if player.is_on_floor():
		return false
	
	# check required collisions
	if not lowerRay.is_colliding() or higherRay.is_colliding() or ceilingCheckRay.is_colliding():
		return false
	
	# check player is moving forward
	var forwardDir = -player.global_transform.basis.z
	var forwardMovement = Vector3(player.velocity.x, 0, player.velocity.z) * forwardDir
	if forwardMovement.length() < 3.0:
		return false
	
	# find wall position
	var wall: RID = RID()
	var wallPosition: Vector3 = Vector3.ZERO
	for i in ledgeCast.get_collision_count():
		var normal = ledgeCast.get_collision_normal(i)
		if abs(normal.y) < 0.3: # check for wall like 
			wall = ledgeCast.get_collider_rid(i)
			wallPosition = ledgeCast.get_collision_point(i)
			break
	
	if not wall.is_valid():
		return false
	
	# find ledge position
	var checkStart = wallPosition + Vector3(0.0, 1.2, 0.0) + (forwardDir * 0.2)
	var checkEnd = checkStart + Vector3.DOWN * 1.5
	
	var downQuery = PhysicsRayQueryParameters3D.create(checkStart, checkEnd)
	downQuery.exclude = [player.get_rid()] # exclude player
	var queryResults = player.get_world_3d().direct_space_state.intersect_ray(downQuery)

	# check ledge is in range
	if not queryResults.is_empty():
		var resultNormal = queryResults.normal
		if resultNormal.y > 0.7: # check floor like
			var heightDiff = lowerRay.global_position.y - queryResults.position.y 

			if abs(heightDiff) > 0.05 and abs(heightDiff) <= maxLedgeSnapHeight:
				executeLedgeAssist(queryResults.position, wall)
				return true
	
	return false

func executeLedgeAssist(ledgePosition: Vector3, wall: RID) -> void:
	PhysicsServer3D.body_add_collision_exception(player.get_rid(), wall)
	
	var heightDiff = player.global_position.y - ledgePosition.y 
	var boostVelocity = sqrt(2.0 * player.playerData.GRAVITY * (heightDiff + 0.2))
	
	player.velocity.y = max(player.velocity.y, boostVelocity)
	
	get_tree().create_timer(ledgeClearanceTime).timeout.connect(func():
		if wall.is_valid():
			PhysicsServer3D.body_remove_collision_exception(player.get_rid(), wall)
	)
