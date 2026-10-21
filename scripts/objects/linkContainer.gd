@tool
extends Node3D
class_name Chain

@export_group("Chain Setup")
@export_range(2, 50) var linkCount: int = 20:
	set(value):
		linkCount = value
		if Engine.is_editor_hint():
			regenerateChain()

@export var linkLength: float = 0.3
@export var linkRadius: float = 0.05

@export_group("Joint Settings")
@export var angularLimitDeg: float = 30.0
@export var twistLimitDeg: float = 15.0

@export_group("Physics Properties")
@export var linkMass: float = 0.5
@export var gravityScale: float = 1.0
@export var linkDamping: float = 0.5

@export_group("Collisions")
@export_flags_3d_physics var linkCollisionLayer: int = 1
@export_flags_3d_physics var linkCollisionMask: int = 1

@export_group("References")
@export var anchor: StaticBody3D
@export var linkContainer: Node3D

var links: Array[RigidBody3D] = []
var joints: Array[Generic6DOFJoint3D] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		generateChain()


func generateChain() -> void:
	# clear link
	clearChain()
	
	# generate links
	for i in range(linkCount):
		var link = createLink(i)
		linkContainer.add_child(link)
		links.append(link)
		link.position = Vector3(0, -(i + 1) * linkLength, 0)
	
	await  get_tree().process_frame
	
	# generate joints
	for i in range(linkCount):
		var bodyA = anchor if i == 0 else links[i - 1]
		var bodyB = links[i]
		
		var joint = createJoint(bodyA, bodyB)
		bodyB.add_child(joint)
		joints.append(joint)


func createLink(index: int) -> RigidBody3D:
	var link = RigidBody3D.new()
	link.name = "Link_" + str(index)
	
	link.mass = linkMass
	link.gravity_scale = gravityScale
	link.linear_damp = linkDamping
	link.angular_damp = linkDamping
	link.collision_layer = linkCollisionLayer
	link.collision_mask = linkCollisionMask
	
	var meshInstance = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = linkLength
	cylinder.top_radius = linkRadius
	cylinder.bottom_radius = linkRadius
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color("9a5942")
	cylinder.material = mat
	meshInstance.mesh = cylinder
	link.add_child(meshInstance)
	
	var collisionShape = CollisionShape3D.new()
	var shape = CylinderShape3D.new()
	shape.height = linkLength
	shape.radius = linkRadius
	collisionShape.shape = shape
	link.add_child(collisionShape)
	
	return link

func createJoint(bodyA: Node3D, bodyB: RigidBody3D) -> Generic6DOFJoint3D:
	var joint = Generic6DOFJoint3D.new()
	joint.name = "Joint_to_" + bodyA.name 
	joint.position = Vector3(0, linkLength * 0.5, 0)
	
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)
	
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)
	
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_LINEAR_LIMIT, true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_LOWER_LIMIT, 0)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_LINEAR_UPPER_LIMIT, 0)
	
	var angularLimitRad = deg_to_rad(angularLimitDeg)
	var twistLimitRad = deg_to_rad(twistLimitDeg)
	
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -angularLimitRad)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, angularLimitRad)
	
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -twistLimitRad)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, twistLimitRad)
	
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -angularLimitRad)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, angularLimitRad)
	
	joint.ready.connect(func():
		joint.node_a = joint.get_path_to(bodyA)
		joint.node_b = NodePath("..")
	) 
	
	return joint

func clearChain() -> void:
	for link in links:
		if is_instance_valid(link):
			link.queue_free()
	links.clear()
	joints.clear()
	
	for child in linkContainer.get_children():
		child.queue_free()


func regenerateChain() -> void:
	if Engine.is_editor_hint():
		clearChain()
		
		await get_tree().physics_frame
		
		generateChain()
