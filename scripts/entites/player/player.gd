extends CharacterBody3D
class_name Player

@export var playerData: Resource
@export var playerSettings: Resource

var direction := Vector3.ZERO

func _physics_process(delta: float) -> void:
	move_and_slide()
