extends Node3D

@export var _playerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	add_player(1)

func add_player(id):
	
	var new_player : Player = _playerScene.instantiate()
	new_player.playerID = id
	new_player.name = str(id)
	new_player.timeSpawned = Time.get_ticks_usec()
	
	$Players.add_child(new_player, true)
	
	
func del_player(id):
	
	if not $Players.has_node(str(id)):
		return
		
	$Players.get_node(str(id)).queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
