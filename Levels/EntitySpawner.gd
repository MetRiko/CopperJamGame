extends Node

onready var level = get_parent().get_parent()
onready var fogOfWar = get_parent().get_node("FogOfWar")

const enemyTscn = preload("res://Entities/Enemy.tscn")

var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	fogOfWar.connect('cells_revealed', self, "cellsRevealed")
	
func enableSpawner():
	enabled = true

func disableSpawner():
	enabled = false
	
func spawnEnemiesWithChance(cells, chance):
	if enabled == false:
		return
		
	for cell in cells:
		var c = randf()
		if c < chance:
			level.createEntity("enemy", cell, false)
	
func cellsRevealed(cells):
	if cells.size() > 70:
		var type = randi() % 16
		if type < 8:
			spawnEnemiesWithChance(cells, 0.02)
		elif type < 12:
			spawnEnemiesWithChance(cells, 0.03)
		elif type <= 15:
			spawnEnemiesWithChance(cells, 0.04)
			
	elif cells.size() > 45:
		var type = randi() % 16
		if type < 8:
			spawnEnemiesWithChance(cells, 0.03)
		elif type < 12:
			spawnEnemiesWithChance(cells, 0.04)
		elif type <= 15:
			spawnEnemiesWithChance(cells, 0.05)
			
	elif cells.size() > 15:
		var type = randi() % 16
		if type < 8:
			spawnEnemiesWithChance(cells, 0.04)
		elif type < 12:
			spawnEnemiesWithChance(cells, 0.05)
		elif type <= 15:
			spawnEnemiesWithChance(cells, 0.06)
	else:
		pass
		
