extends Node

class_name NetworkManager

@export var _levelManager : LevelManager


@export var _debug : bool
@export var _maxLobbySize : int

var init_response : Dictionary

var is_initialized: bool = false
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""

func _ready():
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	multiplayer.peer_connected.connect(_on_player_connected)
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)


func init_steam():
	
	init_response = Steam.steamInit(true, 2329460)
	
	if init_response['status'] == 1:
		print("Initialized Steam!")
		is_initialized = true
	else:
		print("Failed to initialize Steam: %s" % init_response)
		is_initialized = false
	
	# Gather additional data
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	
	if _debug:
		print("Username: " + steam_username)
		print("Steam_ID:" + str(steam_id))
		print("Is Online: " + str(is_online))
		print("Is On Steam Deck: " + str(is_on_steam_deck))
		print("Game is owned: " + str(is_owned))
		
	if not is_owned:
		print("Game is not owned! Shutting down! Piracy is bad mkkay..")
		get_tree().quit()

func create_lobby():
	
	multiplayer.multiplayer_peer = null
	
	if is_online:
		#Create a new lobby and connect to it
		var peer = SteamMultiplayerPeer.new()
		peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_FRIENDS_ONLY, _maxLobbySize)
		multiplayer.multiplayer_peer = peer

func _on_lobby_joined(lobby_id, permissions, locked, response):
	
	if multiplayer.is_server():
		Steam.setLobbyJoinable(lobby_id, true)
		Steam.allowP2PPacketRelay(true)
		
		if _debug:
			print("Created a lobby!")
	
	else:
		print("Joined an existing lobby: " + str(lobby_id))

func _on_lobby_join_requested(lobby_id, friend_id):
	print("Attempting to join " + Steam.getFriendPersonaName(friend_id) + "'s lobby! Lobby ID: " + str(lobby_id))
	
	_levelManager.clear_level()
	
	multiplayer.multiplayer_peer = null
	var peer = SteamMultiplayerPeer.new()
	peer.connect_lobby(lobby_id)
	multiplayer.multiplayer_peer = peer


func _on_player_connected(id):
	print("A player has connected. ID: " + str(id))
	
func _on_connected_ok():
	print("Successfully Established Connection to Multiplayer Peer.")

func _process(_delta: float) -> void:
	
	if is_initialized:
		Steam.run_callbacks()
