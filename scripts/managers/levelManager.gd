extends Node
class_name LevelManager

#@export var levelData: Array[LevelData]
@export var enemyContainer: Node

var enemyArray: Array = []

func _ready() -> void:
	for enemy in enemyContainer.get_children():
		enemyArray.append(enemy)
		enemy.dead.connect(_on_enemy_killed)


func _process(delta: float) -> void:
	pass


func _on_enemy_killed(dead_enemy: Node3D) -> void:
	for i in range(0, enemyArray.size()):
		if dead_enemy == enemyArray[i]:
			enemyArray.remove_at(i)
