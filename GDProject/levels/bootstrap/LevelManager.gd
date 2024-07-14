extends Node

class_name LevelManager

@export var _multiplayerSpawner : MultiplayerSpawner
@export var _networkManager : NetworkManager
@export var _networkSpawnPath : Node
var _currentLevel : Node

@export var _startScene : PackedScene
@export var _playerScene : PackedScene
	
func start_game():
	
	change_level.call_deferred(_startScene.instantiate())

func change_level(scene : Node):
	
	clear_level()
	
	#Add the new scene
	_networkSpawnPath.add_child(scene)
	_currentLevel = scene
	
func clear_level():
	
	#Delete the current scene
	for i in range(0, _networkSpawnPath.get_child_count()):
		_networkSpawnPath.get_child(i).queue_free()
