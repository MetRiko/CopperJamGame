extends Node

export var gridCols := int()
export var gridRows := int()
export var tileWidth := int()
export var tileHeight := int()
var grid = {}
var astar = AStar2D.new()
var obstacles = []

func makeGrid():
	grid = {}
	var r = 0
	var c = 0
	var id = 0
	while r < gridRows:
		c = 0
		while c < gridCols:
			grid[id] = {
				"neighbors":{
					"u":Vector3(c,0,r-1),
					"r":Vector3(c+1,0,r),
					"d":Vector3(c,0,r+1),
					"l":Vector3(c-1,0,r),
				},
				"gridPoint":Vector3(c,0,r),
				"center":Vector3(float(c)+float(tileWidth)/2,0,float(r)+float(tileHeight)/2)
			}
			astar.add_point(id,Vector3(c,0,r))
			c += 1
			id += 1
		r += 1


func getDirectionIds(id,dirs):
	var ids = []
	for d in dirs:
		for i in grid:
			if grid[i].gridPoint == grid[id].neighbors[d]:
				ids.push_back(i)
				continue
	return ids

func connectPoints():
	for tile in grid:
		var ids = getDirectionIds(tile,["u","ru","r","rd","d","ld","l","lu"])
		for i in ids:
			if not astar.are_points_connected(tile,i):
				astar.connect_points(tile,i)

func disconnectPoints():
	for tile in grid:
		disconectPoint(tile)

func disconectPoint(tile):
	var ids = getDirectionIds(tile,["u","ru","r","rd","d","ld","l","lu"])
	for i in ids:
		if astar.are_points_connected(tile,i):
			astar.disconnect_points(tile,i)

func addObstacle():
	var v = Vector3(get_node("AddObstacle/cols").get_value(),0,get_node("AddObstacle/rows").get_value())
	var tile
	for t in grid:
		if grid[t].gridPoint == v:
			tile = t
			continue
	disconectPoint(tile)
	obstacles.push_back(tile)

#^^^tutaj sciany naszej tilemapy^^^

func setObstacles():
	for tile in obstacles:
		disconectPoint(tile)
		makePath()

func makePath():
	var startVector = Vector3(get_node("Start/cols").get_value(),0,get_node("Start/rows").get_value())
	var endVector = Vector3(get_node("End/cols").get_value(),0,get_node("End/rows").get_value())
	var startId = 0
	var endId = 0
	for i in grid:
		if grid[i].gridPoint == startVector:
			startId = i
		
		if grid[i].gridPoint == endVector:
			endId = i
	
	var path = astar.get_id_path(startId,endId)

func _ready():
	makeGrid()
	connectPoints()
	
	#get_node("DrawCardialPath").connect("pressed",self,"setType",["cardnial"])
	#get_node("DrawAllPath").connect("pressed",self,"setType",["all"])
	
	#get_node("Start").connect("valueChanged",self,'makePath')
	#get_node("End").connect("valueChanged",self,'makePath')
	#get_node("AddObstacle/AddObstacleButton").connect("pressed",self,'addObstacle')




