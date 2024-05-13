extends Node3D

var hosting : bool = false
var MazeManager : Maze3D

var mazeSize : Vector3i = Vector3i.ONE*3
var spiders : int = 0
var Maze

var ipAddress : String = ""
const port : int = 4433



func Start():
	MazeManager = get_node("/root/Main") as Maze3D
	if (hosting):
		hostStart()
	else:
		joinStart()


func hostStart():
	#Generate Maze
	Maze = MazeManager.generateMaze(mazeSize.x, mazeSize.z, mazeSize.y)
	MazeManager.constructMaze(Maze)
	
	#Start server
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 8)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(onPeerConnect)
	multiplayer.peer_disconnected.connect(onPeerDisconnect)
	
	#Server person
	var character = preload("res://Assets/Player.tscn").instantiate()
	character.playerID = 1
	character.name = str(1)
	
	playersNode = $"/root/Main/Players"
	playersNode.add_child(character, true)


var playersNode
func onPeerConnect(id:int):
	print("Client connected: " + str(id))
	loadMaze.rpc_id(id, Maze, mazeSize)
	
	var character = preload("res://Assets/Player.tscn").instantiate()
	character.playerID = id
	character.name = str(id)
	playersNode.add_child(character, true)
	#MazeManager.playerCount = len(multiplayer.get_peers())


func onPeerDisconnect(id:int):
	print("Client disconnected: " + str(id))
	if not playersNode.has_node(str(id)):
		return
	playersNode.get_node(str(id)).queue_free()
	MazeManager.players.erase(id)
	#MazeManager.playerCount = len(multiplayer.get_peers())



func joinStart():
	multiplayer.connected_to_server.connect(onConnectToServer)
	multiplayer.connection_failed.connect(onConnectionFailed)
	multiplayer.server_disconnected.connect(onServerDisconnect)
	
	var peer = ENetMultiplayerPeer.new()
	
	var err = peer.create_client(ipAddress, port)
	if (err != 0):
		clientConnectionError(err)
		return
	
	multiplayer.multiplayer_peer = peer


@rpc("reliable")
func loadMaze(maze, MazeSize : Vector3i):
	MazeManager.mazeSize = MazeSize
	MazeManager.constructMaze(maze)


func onConnectToServer():
	print("Connection succeeded")
func onConnectionFailed():
	print("Connection failed")
	clientConnectionError(-70)
func onServerDisconnect():
	print("Connection Lost")
	clientConnectionError(-69)
func clientConnectionError(errorNum : int):
	multiplayer.connected_to_server.disconnect(onConnectToServer)
	multiplayer.connection_failed.disconnect(onConnectionFailed)
	multiplayer.server_disconnected.disconnect(onServerDisconnect)
	
	var errorString := ""
	match errorNum:
		20:
			errorString = "Malformed IP Address"
		-69:
			errorString = "Server Lost Connection (Probably Closed)"
		-70:
			errorString = "Server Did Not Respond"
		_:
			errorString = ""
	
	var errorScreen = load("res://Assets/ClientErrorScreen.tscn").instantiate()
	get_tree().root.add_child(errorScreen)
	errorScreen.setText("({}) {}".format([errorNum, errorString], "{}"))

func disconnectSelf():
	if (not hosting):
		multiplayer.connected_to_server.disconnect(onConnectToServer)
		multiplayer.connection_failed.disconnect(onConnectionFailed)
		multiplayer.server_disconnected.disconnect(onServerDisconnect)
	
	multiplayer.multiplayer_peer = null
