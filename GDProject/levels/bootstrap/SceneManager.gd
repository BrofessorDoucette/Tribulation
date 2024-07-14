extends Node

class_name SceneManager

@export var _networkManager : NetworkManager
@export var _networkSpawnPath : Node
var _currentScene : Node

@export var _startScene : PackedScene
@export var _playerScene : PackedScene
	
func start_game():
	
	change_scene(_startScene.instantiate())
	add_player().possess()

func change_scene(scene : Node):
	
	if _networkManager.is_online:

		_networkManager.create_lobby()
		

	#Delete the current scene
	for i in range(0, _networkSpawnPath.get_child_count()):
		_networkSpawnPath.get_child(i).queue_free()
	
	#Add the new scene
	_networkSpawnPath.add_child(scene)
	_currentScene = scene
	
func add_player():
	var player : Player = _playerScene.instantiate()
	_currentScene.find_child("PlayerSpawn").add_child(player)
	
	return player
	
func player_connected(id):
	var player = add_player()
	player.possess.rpc_id(id)
