extends Node

class_name SceneManager

@export var _networkManager : NetworkManager
@export var _currentScene : Node

func change_scene(scene):
	
	if _networkManager.is_online:

		_networkManager.create_lobby()
		
	
	#Delete the current scene
	for i in range(0, _currentScene.get_child_count()):
		_currentScene.get_child(i).queue_free()
	
	#Add the new scene
	_currentScene.add_child(scene)
