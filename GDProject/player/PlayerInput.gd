extends MultiplayerSynchronizer

@export var _player : Player

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var running := false

# Synchronized property.
@export var direction := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())

func _input(event):
	
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("FreeLook"):
			
			_player.CameraPivot.rotate(Vector3.UP, -1 * _player.MouseSensitivity * deg_to_rad(event.relative.x))
		else:
			_player.turn(event.relative.x)
			
			if not multiplayer.is_server():
				_player.turn.rpc_id(1, event.relative.x)
				
			_player.CameraPivot.rotate(Vector3.RIGHT, -1 * _player.MouseSensitivity * deg_to_rad(event.relative.y))
			_player.CameraPivot.rotation = Vector3(clamp(_player.CameraPivot.rotation.x, -PI/2, PI/2), 0, 0)
			
	if Input.is_action_pressed("CameraZoomIn"):
		_player.CameraOffsetMultiplier = clamp(_player.CameraOffsetMultiplier - _player.CameraOffsetIncrement,
										_player.MinCameraOffsetMultiplier,
										_player.MaxCameraOffsetMultiplier)
	
	if Input.is_action_pressed("CameraZoomOut"):
		_player.CameraOffsetMultiplier = clamp(_player.CameraOffsetMultiplier + _player.CameraOffsetIncrement,
										_player.MinCameraOffsetMultiplier,
										_player.MaxCameraOffsetMultiplier)
	
	_player.Camera.position = _player.CameraOffset * _player.CameraOffsetMultiplier
	
	if Input.is_action_pressed("ToggleFullscreen"):
		
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if Input.is_action_pressed("Jump"):
		jumping = true
	else:
		jumping = false
	
	if Input.is_action_pressed("Run"):
		running = true
	else:
		running = false
	
	direction = Input.get_vector("StrafeLeft", "StrafeRight", "StrafeForward", "StrafeBackward")
