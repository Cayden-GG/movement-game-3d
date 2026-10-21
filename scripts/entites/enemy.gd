extends Area3D
class_name Enemy

signal dead

func _ready() -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area is Bullet:
		dead.emit(self)
		queue_free()
