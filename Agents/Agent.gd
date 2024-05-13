extends CharacterBody3D

var dirs = [Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 0), 
			Vector3(-1, 0, 0), Vector3(0, 0, -1), Vector3(0, -1, 0)]#XZYX'Z'Y'

#Random walk through maze, biased against turning around
var mazeScale = 2
var maze
var targetPosition
var lastDir = -1

func _ready():
	targetPosition = position
	pass

func getNext():
	var pos = Vector3i((position/mazeScale).snapped(Vector3.ONE))
	var walls = maze[pos.x][pos.y][pos.z].walls
	var myDirs = []
	for i in range(len(walls)):
		if not walls[i]:
			myDirs.append(i)
	
	if (len(myDirs) > 1 and lastDir != -1):
		for i in range(len(myDirs)):
			if myDirs[i] == (lastDir+3)%6:
				myDirs.remove_at(i)
				break
	
	lastDir = myDirs[randi()%len(myDirs)]
	var dir = dirs[lastDir]
	var newtpos = targetPosition + Vector3(dir.x, dir.y, dir.z) * mazeScale# + (Vector3.ONE * mazeScale / 2)
	return newtpos


func _process(_delta):
	var dir = targetPosition - position
	if (dir.length() < 0.1):
		targetPosition = getNext()
		dir = targetPosition - position
	
	velocity = dir.normalized() * 10
	move_and_slide()
