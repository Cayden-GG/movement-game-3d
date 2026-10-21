extends Node
class_name GrappleManager

@export var player: Player
@export var playerState: StateMachine
@export var ray: RayCast3D
@export var ROPE_SCENE: PackedScene
@export var gun_barrel_marker: Node3D 

@export var rest_length: float = 1.0
@export var stiffness: float = 10.0
@export var damping: float = 1.0

var rope: Node3D 
var target: Vector3
var launched: bool = false

func _ready() -> void:
	if ROPE_SCENE:
		rope = ROPE_SCENE.instantiate()
		rope.hooked.connect(grappleHooked)
		rope.retracted.connect(grappleRetracted)
		add_child(rope)

func _physics_process(delta: float) -> void:
	if not playerState.current_state.name in ["groundPound"]:
		if Input.is_action_just_pressed("grapple"):
			playerState.current_state.transitioned.emit(playerState.current_state, "idle")
			launch()
	if Input.is_action_just_released("grapple"):
		retract()
	
	if launched:
		handleGrapple(delta)

func launch() -> void:
	if launched: 
		return
	
	target = ray.get_collision_point() if ray.is_colliding() else ray.to_global(ray.target_position)
		
	if rope:
		var inRange = true if ray.is_colliding() else false
		rope.start_grapple(gun_barrel_marker, target, inRange)

func grappleHooked(inRange: bool) -> void:
	if not inRange:
		retract()
		return
	launched = true

func retract() -> void:
	if rope:
		rope.stop_grapple()

func grappleRetracted() -> void:
	launched = false

func handleGrapple(delta: float) -> void:
	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target) 
	
	var displacement = target_dist - rest_length
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		
		var vel_dot = player.velocity.dot(target_dir)
		var damp_force = -damping * vel_dot * target_dir 
		
		spring_force.y += 5.0
		
		force = spring_force + damp_force
	
	player.velocity += force * delta
