extends Area3D
class_name GrindRailAssist

@export var state_machine: StateMachine
var current_rail: GrindRail
var entered: bool = false


func _physics_process(delta: float) -> void:
	if state_machine.current_state.name in ["fall"] and entered:
		state_machine.current_state.transitioned.emit(state_machine.current_state, "railGrind")


func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("rails") and area.has_meta("rail_node"):
		var rail = area.get_meta("rail_node") as GrindRail
		current_rail = rail
		entered = true


func _on_area_exited(area: Area3D) -> void:
	if area.is_in_group("rails") and area.has_meta("rail_node"):
		entered = false
