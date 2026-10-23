extends Node
class_name LevelManager

@onready var current_level: String = get_parent().name
@export var levelCompleteScene: PackedScene = load("res://scenes/menus/level_complete_screen.tscn")
@export var enemyContainer: Node
@export var player: Player

var timerStarted: bool = false
var levelTimer: float = 0.0
var endTime: float = 0.0

var label: Label

var enemyArray: Array = []
var level_data: Dictionary

func _ready() -> void:
	for enemy in enemyContainer.get_children():
		enemyArray.append(enemy)
		enemy.dead.connect(_on_enemy_killed)
	
	create_level_timer()
	
	level_data = GameManager.get_current_level_data(current_level)


func create_level_timer() -> void:
	var canvas = CanvasLayer.new()
	player.add_child(canvas)
	
	var timerLabel = Label.new()
	timerLabel.position = Vector2(0, -5)
	timerLabel.text = "%f" % levelTimer
	label = timerLabel
	canvas.add_child(timerLabel)


func _physics_process(delta: float) -> void:
	var input = Input.get_vector("left", "right", "forward", "backward")
	if input and not timerStarted and levelTimer == 0.0:
		timerStarted = true
	
	if timerStarted:
		levelTimer += delta
		label.text = "%f" % levelTimer
	else: 
		label.text = "%f" % endTime


func _on_enemy_killed(dead_enemy: Node3D) -> void:
	for i in range(0, enemyArray.size()):
		if dead_enemy == enemyArray[i]:
			enemyArray.remove_at(i)


func _on_level_complete() -> void:
	endTime = levelTimer
	timerStarted = false
	
	var completeScreen = levelCompleteScene.instantiate()
	var displayed_best_time = level_data.get("best_time", 999999999)
	completeScreen.best_time = displayed_best_time
	completeScreen.current_time = endTime
	var level_int = get_tree().current_scene.name.split("_")[1]
	completeScreen.current_level = level_int
	
	get_parent().add_child(completeScreen)
	
	var new_level_data = {
		current_level: {
			"complete": true, 
			"best_time": endTime if displayed_best_time == null or endTime < displayed_best_time else displayed_best_time
		}
	}
	
	GameManager.set_current_level_data(new_level_data)
