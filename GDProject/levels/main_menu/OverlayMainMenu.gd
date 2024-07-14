extends HBoxContainer

@export var _startScene : PackedScene
@export var _levelManager : LevelManager
@export var _networkManager: NetworkManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	
	if _networkManager.is_online:
		_networkManager.create_lobby()
		
	_levelManager.start_game()
	
