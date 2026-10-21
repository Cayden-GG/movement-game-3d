extends State
class_name PlayerRailGrind

@export var player: Player
@export var railAssit: GrindRailAssist

var playerData: PlayerMovementData
var playerSettings: PlayerSettings
var grindrail: GrindRail

func enter(prevState: State) -> void:
	grindrail = railAssit.current_rail
	grindrail.attach_player(player)

func exit(nextState: State) -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	if not grindrail:
		return
	
	var jump = false
	if Input.is_action_just_pressed("jump"):
		jump = true
	
	var grindData = grindrail.update_grind(delta, jump)
	
	if not grindData.next_state == "":
		transitioned.emit(self, grindData.next_state)
