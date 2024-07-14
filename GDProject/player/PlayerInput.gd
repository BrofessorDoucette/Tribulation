extends MultiplayerSynchronizer

# Set via RPC to simulate is_action_just_pressed.
@export var jumping := false
@export var running := false

# Synchronized property.
@export var direction := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())
	
@rpc("call_local")
func jump():
	jumping = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("Run"):
		running = true
	
	direction = Input.get_vector("StrafeLeft", "StrafeRight", "StrafeForward", "StrafeBackward")
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()
