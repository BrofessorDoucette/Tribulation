extends Node

class_name Bootstrap

@export var _levelManager : LevelManager
@export var _networkManager: NetworkManager

func _ready():
	
	_networkManager.init_steam()
	
	
