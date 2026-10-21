extends Node3D
class_name Breakable

@export var hitbox: Area3D

@export var max_health: int = 1
@export var takes_damage_from: Array[PackedScene] = []

var current_health

func _ready() -> void:
	current_health = max_health
	hitbox.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area3D) -> void:
	var incoming_node: Node = area.owner if area.owner else area
	if is_valid_breaker(incoming_node):
		current_health -= area.damage if area.damage else 0
		if current_health == 0:
			break_object()


func is_valid_breaker(node: Node) -> bool:
	if node.scene_file_path.is_empty():
		return false
	
	for packed_scene in takes_damage_from:
		if packed_scene and packed_scene.resource_path == node.scene_file_path:
			return true
	
	return false

func break_object() -> void:
	queue_free()
