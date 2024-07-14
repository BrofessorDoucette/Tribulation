extends MultiplayerSynchronizer

class_name TimeSynchronizer

@export var serverTime : int

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if multiplayer.is_server():
		serverTime = Time.get_ticks_usec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if multiplayer.is_server():
		serverTime = Time.get_ticks_usec()
