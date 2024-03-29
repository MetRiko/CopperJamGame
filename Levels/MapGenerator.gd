extends Node

signal new_chunk_generated

const CHUNK_SIZE : int = 16

onready var tilemap : TileMap = get_parent()

onready var level = get_parent().get_parent()

var generatedChunks = []

func getRandomInt(ids):
	return ids[randi()%ids.size()]
#	return (randi()%(to - from + 1)) + from

func getAnyCopper():
	return getRandomInt(level.COPPER)

func getAnyWall():
	return getRandomInt(level.WALL)

func getAnyDarkFloor(cellIdx):
#	var id = int(cellIdx.x + cellIdx.y + 10000000) % 2
#	return getDarkFloors()[id]
	return getRandomInt(level.DARK_FLOOR)

func getAnyFloor():
	return getRandomInt(level.FLOOR)
	
#func getDarkFloors():
#	return [21, 22]
#
#func getFloors():
#	return [15, 16]

	
func noiseFunction(x, y):
		
	var noiseZoom := 6.0
	
	var value := noise(Vector2(x * noiseZoom, y * noiseZoom), cos(x * 0.4) * sin(y * 0.4) * 0.2)
	return 1.0 if value < 0.00000001 else 0.0

func noiseFunctionCopper(x, y, noiseZoom):
		
#	var noiseZoom := 30.0
	
	var value := noise(Vector2(x * noiseZoom, y * noiseZoom), -cos(x * 0.4) * sin(y * 0.4) * 0.2)
	return 1.0 if value < 0.00000001 else 0.0
	
func checkIfChunkExists(x, y):
	for chunk in generatedChunks:
		if chunk[0] == x and chunk[1] == y:
			return true
	return false

func setCell(cellIdx, cellId):
	tilemap.set_cell(cellIdx.x, cellIdx.y, cellId)

func generateChunk(x : int, y : int):
	
	if checkIfChunkExists(x, y):
		return
	
	generatedChunks.append([x, y])
	
	var newCells = []
	
	for ix in range(CHUNK_SIZE):
		for iy in range(CHUNK_SIZE):
			var cellIdx = Vector2(x * CHUNK_SIZE + ix, y * CHUNK_SIZE + iy)
			newCells.append(cellIdx)
			var cell = noiseFunction(cellIdx.x, cellIdx.y)
			var cell2 = 0
			var values = [10.0, 20.0, 30.0]
			for value in values:
				cell2 += noiseFunctionCopper(cellIdx.x, cellIdx.y, value)
#			var cell2 = noiseFunctionCopper(cellIdx.x, cellIdx.y, 30.0) + noiseFunctionCopper(cellIdx.x, cellIdx.y, 20.0)
			if cell2 > 1:
				if cell == 1:
					setCell(cellIdx, getAnyDarkFloor(cellIdx))
				else:
					setCell(cellIdx, getAnyCopper())
			else:
				if cell == 0:
					setCell(cellIdx, getAnyWall())
				else:
					setCell(cellIdx, getAnyDarkFloor(cellIdx))
	
	emit_signal("new_chunk_generated", newCells)
	

func _input(event):
	if event.is_action_pressed("lmb"):
		var mousePos := tilemap.get_global_mouse_position()
		var chunkId = [
			floor(mousePos.x / (16 * 32)),
			floor(mousePos.y / (16 * 32))
		]
		generateChunk(chunkId[0], chunkId[1])

var randSeed = 0
onready var rng = RandomNumberGenerator.new()

func _ready():
	randomize()
#	randSeed = randf()

func fract(x : float) -> float:
	return x - floor(x)

func setSeed(seeed : float):
#	rng.seed  = seeed
	randSeed = seeed

func getRandf():
	return rng.randf()

func random3vec3(c : Vector3) -> Vector3:
	var j := 4096.0*sin(c.dot(Vector3(17.0, 59.4, 15.0)))
	var r := Vector3()
	var randValue = randSeed
	r.z = fract(512.0*j + randValue)
	j *= .125
	r.x = fract(512.0*j + randValue)
	j *= .125
	r.y = fract(512.0*j + randValue)
	return r-Vec3(0.5)

#func random3vec3(c : Vector3) -> Vector3:
#	var j := 4096.0*sin(c.dot(Vector3(17.0, 59.4, 15.0)))
#	var r := Vector3()
#	r.z = fract(512.0*j + randSeed)
#	j *= .125
#	r.x = fract(512.0*j + randSeed)
#	j *= .125
#	r.y = fract(512.0*j + randSeed)
#	return r-Vec3(0.5)

func random3():
	return Vector3(randf(), randf(), randf())

const F3 = 0.3333333;
const G3 = 0.1666667;

func floor3(vec3 : Vector3):
	return Vector3(floor(vec3.x), floor(vec3.y), floor(vec3.z))

func Vec3(v : float) -> Vector3:
	return Vector3(v, v, v)

func step(edge : float, x : float):
	return 0.0 if x < edge else 1.0

func step3(edge : Vector3, x : Vector3) -> Vector3:
	return Vector3(
		step(edge.x, x.x),
		step(edge.y, x.y),
		step(edge.z, x.z)
	)

func simplex3d(p : Vector3) -> float:
	#vec3 s = floor(p + dot(p, vec3(F3)));
	var sdot := p.dot(Vec3(F3))
	var s := Vector3(floor(p.x + sdot), floor(p.y + sdot), floor(p.z + sdot))
	
	#vec3 x = p - s + dot(s, vec3(G3))
	var x := Vec3(s.dot(Vec3(G3))) - s + p 
	
	#vec3 e = step(vec3(0.0), x - x.yzx)
	var e := step3(Vector3(), x - Vector3(x.y, x.z, x.x))
	
	#vec3 i1 = e*(1.0 - e.zxy)
	var i1 := e*(Vec3(1.0) - Vector3(e.z, e.x, e.y))
	
	#vec3 i2 = 1.0 - e.zxy*(1.0 - e)
	var i2 := Vec3(1.0) - Vector3(e.z, e.x, e.y)*(Vec3(1.0) - e)

	#vec3 x1 = x - i1 + G3
	var x1 := x - i1 + Vec3(G3)
	
	#vec3 x2 = x - i2 + 2.0*G3
	var x2 := x - i2 + 2.0 * Vec3(G3) 

	#vec3 x3 = x - 1.0 + 3.0*G3
	var x3 := x - Vec3(1.0) + 3.0 * Vec3(G3)

	#vec4 w, d;
	var w := [0,0,0,0]
	var d := [0,0,0,0]

#	w.x = dot(x, x)
#	w.y = dot(x1, x1)
#	w.z = dot(x2, x2)
#	w.w = dot(x3, x3)
	w[0] = x.dot(x)
	w[1] = x1.dot(x1)
	w[2] = x2.dot(x2)
	w[3] = x3.dot(x3)

#	w = max(0.6 - w, 0.0)
	w[0] = max(0.6 - w[0], 0.0)
	w[1] = max(0.6 - w[1], 0.0)
	w[2] = max(0.6 - w[2], 0.0)
	w[3] = max(0.6 - w[3], 0.0)

#	d.x = dot(random3(s), x)
#	d.y = dot(random3(s + i1), x1)
#	d.z = dot(random3(s + i2), x2)
#	d.w = dot(random3(s + 1.0), x3)
	d[0] = random3vec3(s).dot(x)
	d[1] = random3vec3(s + i1).dot(x1)
	d[2] = random3vec3(s + i2).dot(x2)
	d[3] = random3vec3(s + Vec3(1.0)).dot(x3)

#	w *= w;
#	w *= w;
#	d *= w;
	d[0] = d[0] * w[0] * w[0]
	d[1] = d[1] * w[1] * w[1]
	d[2] = d[2] * w[2] * w[2]
	d[3] = d[3] * w[3] * w[3]

#	return dot(d, vec4(52.0))
	return d[0] * 52.0 + d[1] * 52.0 + d[2] * 52.0 + d[3] * 52.0

func fbm(xy : Vector2, z : float, octs : int) -> float:
	var f := 1.4 #1.0
	var a := 0.6 #1.0
	var t := 0.0
	var a_bound := 0.0
	
	for i in range(octs):
		var temp = xy*f
		t += a*simplex3d(Vector3(temp.x, temp.y, z*f))
		f *= 2.0
		a_bound += a
		a *= 0.5
	
	return t/a_bound;

func noise_final_comp(xy : Vector2, z : float) -> float:
	var value := fbm(Vector2(xy.x / 200.0+513.0, xy.y / 200.0+124.0), z, 3)
	value = 1.0-abs(value)
	value = value*value
	return value*2.0-1.0
	
func noise(xy : Vector2, z : float) -> float:
	var value := fbm(
		Vector2((xy.x) / 100.0, (xy.y) / 100.0), 
		z*1.5, 1
	)
				 
	return max(0.0, min(1.0, (value*0.5+0.5)*1.3));
