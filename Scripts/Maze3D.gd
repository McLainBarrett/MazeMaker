extends Node3D
class_name Maze3D
#https://en.wikipedia.org/wiki/Maze_generation_algorithm	Wilson's Algorithm

var mazeSize = Vector3i(7, 7, 3)

var dirs = [Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0), 
			Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)]#XZYX'Z'Y'

class Cell:
	func _init(pos:Vector3):
		position = pos
	var position : Vector3 = Vector3.ZERO
	var walls : Array = [true, true, true, true, true, true]
	#Construction Vars
	var IN : bool = false
	var dir : int = 0


func generateMaze(Length, Width, Height):
	mazeSize = Vector3(Length, Height, Width)
	var getNext = func(pos:Vector3):#Return in-bounds direction
		while true:
			var dir = randi()%6
			var newPos = dirs[dir]+pos
			if (0 <= newPos.x and newPos.x < Length 
					and 0 <= newPos.z and newPos.z < Width
					and 0 <= newPos.y and newPos.y < Height):#Check if in bounds
				return dir
	
	#Grid of empty cells
	var maze = []
	for x in range(Length):
		maze.append([])
		for y in range(Height):
			maze[x].append([])
			for z in range(Width):
				maze[x][y].append(Cell.new(Vector3(x, y, z)))
	
	#Randomly choose one to set as 'in'
	maze[randi()%Length][randi()%Height][randi()%Width].IN = true
	
	#Keep count of how many cells are OUT
	var outCount = Length*Height*Width-1
	
	#Until all cells are IN:
		#Random walk from random out cell until in IN cell
	
	var limit = 10000 #Just in case
	while (outCount > 0 and limit > 0):
		limit -= 1
		var path = []
		#Get random OUT starting point
		while true:
			var cell = maze[randi()%Length][randi()%Height][randi()%Width]#Rather inefficent, eh?
			if (not cell.IN):
				cell.dir = getNext.call(cell.position)
				path.append(cell)
				break
		
		#Random walk, add to path
		var lim2 = 10000#Again, just in case
		while lim2 > 0:
			lim2 -= 1
			#Choose direction randomly from current pos
			var pos = path[-1].position + dirs[path[-1].dir]
			var dir = getNext.call(pos)
			#Add cell to path, update direction
			var cell = maze[pos.x][pos.y][pos.z]
			if (not cell.IN):#Unless already in maze
				cell.dir = dir
				path.append(cell)
			else:
				break
		
		#Iterate through walk, add to maze
		lim2 = 10000
		var currentCell = path[0]
		var trace = []
		while lim2 > 0:
			lim2 -= 1 
			if not currentCell.IN:
				var dir = currentCell.dir
				var pos = dirs[dir] + currentCell.position
				trace.append(currentCell)
				
				currentCell = maze[pos.x][pos.y][pos.z]
			else:
				break
				
		for cell in trace:
			cell.IN = true
			outCount -= 1
			cell.walls[cell.dir] = false
			
			var nextPos = cell.position+dirs[cell.dir]
			maze[nextPos.x][nextPos.y][nextPos.z].walls[(cell.dir+3)%6] = false
	
	#return maze
	#Convert maze to 4d boolean array [x][y][z][wall]
	var boolMaze = []
	for x in range(Length):
		boolMaze.append([])
		for y in range(Height):
			boolMaze[x].append([])
			for z in range(Width):
				boolMaze[x][y].append([])
				for w in range(6):
					boolMaze[x][y][z].append(maze[x][y][z].walls[w])
	return boolMaze

func constructMaze(Maze):
	$Exit.position = Vector3(mazeSize.x-1, mazeSize.z-1, mazeSize.y-1) * 2
	var Wall = "res://Assets/Wall.tscn"
	var mazeScale = 2
	
	for x in range(len(Maze)):
		for y in range(len(Maze[x])):
			for z in range(len(Maze[x][y])):
				var pos = Vector3(x, y, z) * mazeScale
				for w in range(6):
					if (Maze[x][y][z][w]):
						var wall = load(Wall).instantiate()
						add_child(wall)
						var offset = dirs[w] * mazeScale/2
						wall.position = pos + Vector3(offset.x, offset.y, offset.z)# + (Vector3.ZERO if pos != Vector3.ZERO else Vector3(0, 1, 0))
						var rots = [0, PI/2, PI/2, PI, 3*PI/2, PI/2]
						if (w%3==2):
							wall.rotation = Vector3(0, 0, rots[w])#It is up/down wall
						else:
							wall.rotation = Vector3(0, rots[w], 0)

#func constructMaze3D(Maze):
#	$Exit.position = Vector3(mazeSize.x-1, mazeSize.z-1, mazeSize.y-1) * 2
#	var Wall = "res://Assets/Wall.tscn"
#	var mazeScale = 2
#
#	for x in range(len(Maze)):
#		for y in range(len(Maze[x])):
#			for z in range(len(Maze[x][y])):
#				var pos = Vector3(x, y, z) * mazeScale
#				for i in range(6):
#					if (Maze[x][y][z].walls[i]):
#						var wall = load(Wall).instantiate()
#						add_child(wall)
#						var offset = dirs[i] * mazeScale/2
#						wall.position = pos + Vector3(offset.x, offset.y, offset.z)# + (Vector3.ZERO if pos != Vector3.ZERO else Vector3(0, 1, 0))
#						var rots = [0, PI/2, PI/2, PI, 3*PI/2, PI/2]
#						if (i%3==2):
#							wall.rotation = Vector3(0, 0, rots[i])#It is up/down wall
#						else:
#							wall.rotation = Vector3(0, rots[i], 0)

func spawnEnemy(Maze):
	var enemy = load("res://Agents/RedSpider.tscn").instantiate()
	get_parent().add_child.call_deferred(enemy)
	enemy.position = Vector3(randi() % mazeSize.x, randi() % mazeSize.z, randi() % mazeSize.y) * 2
	enemy.maze = Maze
	pass

func _ready():
	OVERLORD.Start()
#	var maze = generateMaze(mazeSize.x, mazeSize.y, mazeSize.z)
#	constructMaze3D(maze)
#	spawnEnemy(maze)
#	$Exit.position = Vector3(mazeSize.x-1, mazeSize.z-1, mazeSize.y-1) * 2


#Goals
func _process(_delta: float) -> void:
	if (len(players) >= $Players.get_child_count() and len(players) > 0):
		backtracking = not backtracking
		players = {}
		$Exit.visible = not backtracking
		$Entrance.visible = backtracking
		

var backtracking = false
var players = {}
func onPlayerExit(body: Node3D) -> void:
	var player := body as PlayerBody
	if (player and not players.has(player.playerID) and not backtracking):
		players[player.playerID] = true


func onPlayerEnter(body: Node3D) -> void:
	var player := body as PlayerBody
	if (player and not players.has(player.playerID) and backtracking):
		players[player.playerID] = true
