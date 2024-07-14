extends Node

class_name Bootstrap

@export var _sceneManager : SceneManager
@export var _networkManager: NetworkManager

func _ready():
	
	_networkManager.init_steam()
	
	
