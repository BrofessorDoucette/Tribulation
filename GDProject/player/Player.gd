extends CharacterBody3D

class_name Player

@export_category("Player Controller")
@export var MouseSensitivity = 5.0
@export var _walkSpeed = 5.0
@export var _runSpeed = 10.0
@export var _jumpVelocity = 4.5
var _moveSpeed = 0

@export_category("Camera")
@export var CameraPivot : Node3D
@export var Camera : Camera3D
@export var _rayCast : RayCast3D
@export var CameraOffset : Vector3
@export var DefaultCameraOffsetMultiplier : float
@export var MinCameraOffsetMultiplier : float
@export var MaxCameraOffsetMultiplier : float
@export var CameraOffsetIncrement : float
var CameraOffsetMultiplier : float

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Networking
# Set by the authority, synchronized on spawn.
@export var playerID := 1 :
	set(id):
		playerID = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

@export var _serverTime : int = 0

var _frame = 0
var _framesBetweenRecords = 5
var _framesBetweenSyncRequest = 60
var _timesRecorded = []
var _positionsRecorded = []
var _rotationYRecorded = []

func _ready():
	
	if playerID == multiplayer.get_unique_id():
		Camera.current = true
	
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CameraOffsetMultiplier = clamp(DefaultCameraOffsetMultiplier,
										MinCameraOffsetMultiplier,
										MaxCameraOffsetMultiplier)
										
		Camera.position = CameraOffset * CameraOffsetMultiplier
	

@rpc("authority", "call_remote", "unreliable")
func sync(serverTime, serverPosition, serverRotationY):
	
	var closest_index = _timesRecorded.bsearch(serverTime)
	var historicalPosition = _positionsRecorded[closest_index]
	var historicalRotationY = _rotationYRecorded[closest_index]
	
	var dP = serverPosition - historicalPosition
	var dR = serverRotationY - historicalRotationY
	
	position = position - dP
	rotation.y = serverRotationY - dR

@rpc("any_peer", "call_local", "unreliable")
func turn(mouseDeltaX):
	
	rotate_y(-1 * MouseSensitivity * deg_to_rad(mouseDeltaX))

func _physics_process(delta):
	
	if multiplayer.is_server():
		_serverTime = Time.get_ticks_usec()
	
	if _frame % 120 == 0:
		if playerID == multiplayer.get_unique_id():
			print("Server Time: " + str(_serverTime))
			
	if _frame % _framesBetweenRecords == 0:
		_timesRecorded.append(_serverTime)
		_positionsRecorded.append(position)
		_rotationYRecorded.append(rotation.y)
		
	if multiplayer.is_server():
		if _frame % _framesBetweenSyncRequest == 0:
			sync.rpc(_serverTime, position, rotation.y)

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
	
	_frame += 1
	
	
	
	
