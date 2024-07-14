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

var _frame = 0
var _framesBetweenRecords = 1
var _framesBetweenSyncRequest = 5
var _seqRecorded = []
var _positionsRecorded = []
var _rotationYRecorded = []
var _velocitiesRecorded = []

func _ready():
	
	if playerID == multiplayer.get_unique_id():
		Camera.current = true
	
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CameraOffsetMultiplier = clamp(DefaultCameraOffsetMultiplier,
										MinCameraOffsetMultiplier,
										MaxCameraOffsetMultiplier)
										
		Camera.position = CameraOffset * CameraOffsetMultiplier
		
	
	

@rpc("authority", "call_remote", "unreliable")
func sync(seq, serverPosition, serverRotationY, serverVelocity):
	
	if len(_seqRecorded) == 0:
		return
	
	print("Syncing")
	
	var closest_index = _seqRecorded.bsearch(seq)
	
	if closest_index > len(_seqRecorded):
		return
		
	print("Seq asked for : " + str(seq), "Seq found: " + str(_seqRecorded[closest_index]))
	
	var historicalPosition = _positionsRecorded[closest_index]
	var historicalRotationY = _rotationYRecorded[closest_index]
	var historicalVelocity = _velocitiesRecorded[closest_index]
	
	var dP = position - historicalPosition
	var dR = rotation.y - historicalRotationY
	var dV = velocity - historicalVelocity
	
	position = serverPosition + dP
	rotation.y = serverRotationY + dR
	velocity = serverVelocity + dV

@rpc("any_peer", "call_local", "unreliable")
func turn(mouseDeltaX):
	
	rotate_y(-1 * MouseSensitivity * deg_to_rad(mouseDeltaX))

func _physics_process(delta):
			
	_seqRecorded.append($PlayerInput.seq)
	_positionsRecorded.append(position)
	_rotationYRecorded.append(rotation.y)
	_velocitiesRecorded.append(velocity)
		
	if multiplayer.is_server():
		if _frame % (_framesBetweenSyncRequest) == 0:
			sync.rpc($PlayerInput.seq, position, rotation.y, velocity)

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
	
	
	
	
