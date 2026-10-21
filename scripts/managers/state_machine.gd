extends Node
class_name StateMachine

@onready var label: Label = $"../HUD/Label"

@export var inital_state: State

var current_state: State
var states: Dictionary =  {}
var stateHistory: Array = []


func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
	
	if inital_state: 
		inital_state.enter(inital_state)
		current_state = inital_state


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func on_child_transition(state, new_state_name) -> void:
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.exit(new_state)
	
	new_state.enter(current_state)
	
	updateStateHistory(new_state)
	
	current_state = new_state

func updateStateHistory(newState: State) -> void:
	stateHistory.insert(0, newState.name)
	
	if stateHistory.size() > 7:
		stateHistory.pop_back()
	
	var string: String = ""
	for i in range(0, stateHistory.size()):
		string += "%s\n" % stateHistory[i]
		
	label.text = string
