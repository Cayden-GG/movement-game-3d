extends Node3D
class_name GrappleRope

signal hooked
signal retracted

@onready var csg: CSGPolygon3D = $Path3D/CSGPolygon3D
@onready var camera: Camera3D = $"../../head/Camera3D"
@onready var player: Player = $"../.."

@export var max_sag: float = 2.5
@export var rope_radius: float = 0.05
@export var smooth_tension_speed: float = 10.0

@export var throw_speed: float = 60.0 
@export var retract_speed: float = 80.0

@onready var path: Path3D = $Path3D

var is_grappling: bool = false
var in_range: bool 
var has_hit: bool = false
var is_retracting: bool = false

var current_target: Vector3
var gun_barrel_node: Node3D

var current_length: float = 0.0
var rope_tension: float = 0.0 
var hit_distance: float = 0.0

func _ready() -> void:
	# 1. Procedurally generate a perfect circle for the rope cross-section
	var circle_points = PackedVector2Array()
	var segments = 8
	for i in range(segments):
		var angle = (float(i) / segments) * TAU
		circle_points.append(Vector2(cos(angle), sin(angle)) * rope_radius)
	csg.polygon = circle_points
	
	# 2. Initialize the curve with exactly 3 points
	path.curve = Curve3D.new()
	path.curve.add_point(Vector3.ZERO) # Start
	path.curve.add_point(Vector3.ZERO) # Middle (Sag)
	path.curve.add_point(Vector3.ZERO) # End
	
	visible = false

func _process(delta: float) -> void:
	if not is_grappling or not is_instance_valid(gun_barrel_node):
		visible = false
		return
		
	visible = true
	global_position = Vector3.ZERO 

	var pt_start = gun_barrel_node.global_position
	var total_dist = pt_start.distance_to(current_target)
	
	# --- 1. HANDLE LENGTH (LAUNCH VS RETRACT) ---
	if is_retracting:
		# Shrink the rope back to the gun
		current_length = move_toward(current_length, 0.0, retract_speed * delta)
		
		# When fully retracted, finally turn it off
		if current_length <= 0.0:
			is_grappling = false
			is_retracting = false
			visible = false
			retracted.emit()
			return
	else:
		# Animate outward
		current_length = move_toward(current_length, total_dist, throw_speed * delta)
		camera.scaleFOV(delta, player.playerData.BASE_FOV - 6)
	
	var throw_ratio = 0.0
	if total_dist > 0.001:
		throw_ratio = current_length / total_dist
		
	# The visual tip of the rope moving
	var animated_end = pt_start.lerp(current_target, throw_ratio)
	
	# --- 2. CALCULATE TENSION & SAG ---
	var pt_mid = pt_start.lerp(animated_end, 0.5)
	
	if is_retracting:
		# Release tension instantly so the rope goes slack as it flies back
		rope_tension = move_toward(rope_tension, 0.0, smooth_tension_speed * delta)
		
	elif current_length >= total_dist:
		if not has_hit:
			has_hit = true
			hit_distance = total_dist
			hooked.emit(in_range)
			
		var slack = max(0.0, hit_distance - total_dist)
		var target_tension = 1.0 - clamp(slack * 0.15, 0.0, 0.8) 

		var time = Time.get_ticks_msec() / 1000.0
		var wobble = sin(time * 25.0) * 0.02
		target_tension -= wobble
		
		rope_tension = move_toward(rope_tension, target_tension, smooth_tension_speed * delta)
	else:
		rope_tension = 0.0
		
	var current_sag = max_sag * (1.0 - rope_tension) * throw_ratio
	pt_mid.y -= current_sag

	# --- 3. APPLY TO CURVE ---
	path.curve.set_point_position(0, pt_start)
	path.curve.set_point_position(1, pt_mid)
	path.curve.set_point_position(2, animated_end)

	var tangent = (animated_end - pt_start) * 0.25
	tangent.y = 0 
	
	if current_sag < 0.01:
		tangent = Vector3.ZERO
		
	path.curve.set_point_in(1, -tangent)
	path.curve.set_point_out(1, tangent)

# Call this from your Grapple State
func start_grapple(gun_node: Node3D, target_point: Vector3, in_range: bool) -> void:
	gun_barrel_node = gun_node
	current_target = target_point
	is_grappling = true
	is_retracting = false 
	rope_tension = 0.0 
	current_length = 0.0
	
	self.in_range = in_range
	
	has_hit = false
	hit_distance = 0.0

func stop_grapple() -> void:
	is_retracting = true
