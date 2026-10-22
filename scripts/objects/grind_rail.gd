extends Node3D
class_name GrindRail

@export var path: Path3D 
@export var path_follow: PathFollow3D

@export var min_grind_speed: float = 22.0
@export var jump_launch_force: float = 1.0
@export var trigger_radius: float = 1.0
@export var segment_step: float = 2.0
@export var pipe_radius: float = 0.05 
@export var pipe_sides: int = 8
@export var rail_material: Material  

var area: Area3D
var attached_player: Player
var grind_direction: float = 1.0
var current_speed: float = 0.0

var attach_timer: float = 0.2
var cur_attach_timer: float 

func _ready() -> void:
	path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	path_follow.use_model_front = true
	
	_generate_rail_area()
	_generate_rail_mesh()

func attach_player(player: Player) -> bool:
	if not path or not path.curve:
		return false
	
	attached_player = player
	cur_attach_timer = attach_timer
	
	# find player location on the rail
	var local_pos = path.to_local(player.global_position)
	path_follow.progress = path.curve.get_closest_offset(local_pos)
	
	current_speed = max(player.velocity.length(), min_grind_speed)
	
	var rail_forward = -path_follow.global_transform.basis.z
	if not path.curve.closed:
		rail_forward *= -1
		
	if player.velocity.length_squared() > 0.1:
		grind_direction = 1.0 if player.velocity.dot(rail_forward) >= 0.0 else -1.0
	else:
		grind_direction = 1.0
	
	return true


func update_grind(delta: float, want_jump: bool) -> Dictionary:
	if not attached_player:
		return { "is_grinding": false, "exit_velocity": Vector3.ZERO, "next_state": "fall" }
	
	if want_jump:
		var exit_vel = _detach_player(jump_launch_force)
		return { "is_grinding": false, "exit_velocity": exit_vel, "next_state": "jump" }
	
	path_follow.progress += current_speed * grind_direction * delta
	attached_player.global_position = path_follow.global_position
	cur_attach_timer -= delta
	
	# Update velocity vector using the native orientation basis
	var rail_forward = -path_follow.global_transform.basis.z
	attached_player.velocity = rail_forward * current_speed * grind_direction
	
	# End of rail detection
	var rail_length = path.curve.get_baked_length()
	if cur_attach_timer <= 0:
		if  rail_length - path_follow.progress <= 0.25 or path_follow.progress <= 0.25:
			var exit_vel = _detach_player(0.0)
			return { "is_grinding": false, "exit_velocity": exit_vel, "next_state": "jump" }
	
	return { "is_grinding": true, "exit_velocity": Vector3.ZERO, "next_state": "" }

func _detach_player(up_force: float) -> Vector3:
	var rail_forward = path_follow.global_transform.basis.z
	var exit_vel = (rail_forward * current_speed * grind_direction) + (Vector3.UP * up_force)
	attached_player.velocity = exit_vel
	attached_player = null
	return exit_vel


func _generate_rail_area() -> void:
	if not path or not path.curve:
		return
	
	# 1. Create Area3D node dynamically
	area = Area3D.new()
	area.name = "RailTriggerArea"
	add_child(area)
	
	area.add_to_group("rails")
	area.set_meta("rail_node", self)
	
	var curve = path.curve
	curve.bake_interval = segment_step
	var points = curve.get_baked_points()
	
	if points.size() < 2:
		return
	
	for i in range(points.size() - 1):
		var p1 = points[i]
		var p2 = points[i + 1]
		var segment = p2 - p1
		var length = segment.length()
	
		if length < 0.001:
			continue
	
		var col = CollisionShape3D.new()
		var box = BoxShape3D.new()
		box.size = Vector3(trigger_radius * 2.0, trigger_radius * 2.0, length)
		col.shape = box
	
		area.add_child(col)
	
		# Position collider at segment midpoint
		var midpoint = p1 + (segment * 0.5)
		col.position = midpoint
	
		# Orient collider along segment vector (fallback UP if vertical rail)
		var up = Vector3.UP if abs(segment.normalized().y) < 0.99 else Vector3.FORWARD
		col.transform = Transform3D().looking_at(segment, up)
		col.position = midpoint

func _generate_rail_mesh() -> void:
	if not path or not path.curve:
		return

	var curve = path.curve
	curve.bake_interval = 0.01 # Higher sampling density for smooth visual geometry
	var points = curve.get_baked_points()

	if points.size() < 2:
		return

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	# 1. Generate rings of vertices along the curve
	for i in range(points.size()):
		var p = points[i]
		
		# Calculate forward direction tangent at current point
		var forward: Vector3
		if i < points.size() - 1:
			forward = (points[i + 1] - p).normalized()
		else:
			forward = (p - points[i - 1]).normalized()

		# Build local coordinate frame perpendicular to forward vector
		var up = Vector3.UP if abs(forward.y) < 0.99 else Vector3.FORWARD
		var right = forward.cross(up).normalized()
		up = right.cross(forward).normalized()

		# Place circle vertices around the path point
		for s in range(pipe_sides):
			var angle = (float(s) / float(pipe_sides)) * TAU
			var offset = (right * cos(angle) + up * sin(angle)) * pipe_radius
			var vertex = p + offset
			var normal = offset.normalized()
			var uv = Vector2(float(s) / float(pipe_sides), float(i) / float(points.size()) * 10.0)

			st.set_normal(normal)
			st.set_uv(uv)
			st.add_vertex(vertex)

	# 2. Connect vertex rings with triangle indices
	for i in range(points.size() - 1):
		for s in range(pipe_sides):
			var current_ring = i * pipe_sides
			var next_ring = (i + 1) * pipe_sides

			var current_v = current_ring + s
			var next_v = current_ring + ((s + 1) % pipe_sides)
			var current_next_v = next_ring + s
			var next_next_v = next_ring + ((s + 1) % pipe_sides)

			# First triangle
			st.add_index(current_v)
			st.add_index(next_v)
			st.add_index(current_next_v)

			# Second triangle
			st.add_index(next_v)
			st.add_index(next_next_v)
			st.add_index(current_next_v)

	# 3. Create MeshInstance3D and apply material
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "ProceduralRailMesh"
	mesh_instance.mesh = st.commit()

	if rail_material:
		mesh_instance.material_override = rail_material

	add_child(mesh_instance)
