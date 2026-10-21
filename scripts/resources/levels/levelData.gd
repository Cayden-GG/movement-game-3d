extends Resource
class_name LevelData

@export_range(1, 100, 1, "prefer_slider") var LEVEL_ENEMY_COUNT: int = 1

## Enemy scene : enemy count in level
@export var LEVEL_ENEMIES: Dictionary[PackedScene, int] = {}
