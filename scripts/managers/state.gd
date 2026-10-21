extends Node
class_name State

signal transitioned

func enter(prevState: State) -> void:
	pass

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass
