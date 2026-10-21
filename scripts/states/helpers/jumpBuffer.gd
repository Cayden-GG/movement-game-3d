extends Timer

@export var player: Player
var reset: bool = true

func _process(delta: float) -> void:
	if not player.is_on_floor() and reset:
		reset = false
		start(player.playerData.JUMP_BUFFER)


func resetTimer() -> void:
	reset = true
