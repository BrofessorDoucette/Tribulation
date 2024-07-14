extends CharacterBody3D

class_name Player

@export_category("Player Controller")
@export var _mouseSensitivity = 5.0
@export var _walkSpeed = 5.0
@export var _runSpeed = 10.0
@export var _jumpVelocity = 4.5
var _moveSpeed = 0

@export_category("Camera")
@export var _cameraPivot : Node3D
@export var _camera : Camera3D
@export var _rayCast : RayCast3D
@export var _cameraOffset : Vector3
@export var _defaultCameraOffsetMultiplier : float
@export var _minCameraOffsetMultiplier : float
@export var _maxCameraOffsetMultiplier : float
@export var _cameraOffsetIncrement : float
var _cameraOffsetMultiplier : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Networking
# Set by the authority, synchronized on spawn.
@export var playerID := 1 :
	set(id):
		playerID = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)


func _ready():
	
	if playerID == multiplayer.get_unique_id():
		_camera.current = true
	
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_cameraOffsetMultiplier = clamp(_defaultCameraOffsetMultiplier,
										_minCameraOffsetMultiplier,
										_maxCameraOffsetMultiplier)
										
		_camera.position = _cameraOffset * _cameraOffsetMultiplier

@rpc("call_remote", "reliable", "authority")
func possess():
	_camera.current = true

func _input(event):
	
	if event is InputEventMouseMotion:
		
		if not Input.is_action_pressed("FreeLook"):
			rotate_y(-1 * _mouseSensitivity * deg_to_rad(event.relative.x))
			_cameraPivot.rotate(Vector3.RIGHT, -1 * _mouseSensitivity * deg_to_rad(event.relative.y))
		else:
			_cameraPivot.rotate(Vector3.UP, -1 * _mouseSensitivity * deg_to_rad(event.relative.x))
		
		_camera.position = _cameraOffset * _cameraOffsetMultiplier
	
	if Input.is_action_pressed("CameraZoomIn"):
		_cameraOffsetMultiplier = clamp(_cameraOffsetMultiplier - _cameraOffsetIncrement,
										_minCameraOffsetMultiplier,
										_maxCameraOffsetMultiplier)
	
	if Input.is_action_pressed("CameraZoomOut"):
		_cameraOffsetMultiplier = clamp(_cameraOffsetMultiplier + _cameraOffsetIncrement,
										_minCameraOffsetMultiplier,
										_maxCameraOffsetMultiplier)
	
	_camera.position = _cameraOffset * _cameraOffsetMultiplier
	
	if Input.is_action_pressed("ToggleFullscreen"):
		
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _process(delta):
	
	if not Input.is_action_pressed("FreeLook"):
		_cameraPivot.rotation = Vector3(clamp(_cameraPivot.rotation.x, -PI/2, PI/2), 0, 0)

func _physics_process(delta):
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if $PlayerInput.jumping and is_on_floor():
		velocity.y = _jumpVelocity
		
	if $PlayerInput.running:
		_moveSpeed = _runSpeed
	else:
		_moveSpeed = _walkSpeed

	var direction = (transform.basis * Vector3($PlayerInput.direction.x, 0, $PlayerInput.direction.y)).normalized()
	if direction:
		velocity.x = direction.x * _moveSpeed
		velocity.z = direction.z * _moveSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, _moveSpeed)
		velocity.z = move_toward(velocity.z, 0, _moveSpeed)
	
	move_and_slide()
	
	$PlayerInput.jumping = false
	$PlayerInput.running = false
