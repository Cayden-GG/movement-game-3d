extends Resource
class_name PlayerSettings

@export var toggleCrouch: bool = true
@export var toggleSprint: bool = true

@export_range(0.01, 1, 0.01) var MOUSE_SENS: float = 0.04
@export_range(1.0,10, 0.1) var CONTROLLER_SENS: float = 5.0
