extends Area3D
class_name Door

#@export var levelData: LevelData
@export var levelManager: LevelManager

#var levelEnemiesCount: int
#var enemiesLeft: int

#func _ready() -> void:
	#pass
	#levelEnemiesCount = levelData.LEVEL_ENEMY_COUNT
	#enemiesLeft = levelData.LEVEL_ENEMY_COUNT	


func _on_body_entered(body: Node3D) -> void:
	if not levelManager: 
		return
	
	if body is Player and levelManager.enemyArray.size() == 0:
		print("level complete")
		levelManager.endTime = levelManager.levelTimer
		levelManager.timerStarted = false
