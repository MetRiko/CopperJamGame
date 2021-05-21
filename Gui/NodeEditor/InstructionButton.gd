extends Button

var instructionData = null

func setInstructionData(instructionData):
	if instructionData != null:
		self.instructionData = instructionData
#		text = instructionData.name
		disabled = false
		$Sprite.visible = true
		$Sprite.frame = instructionData.frameId
	else:
		disabled = true
		$Sprite.visible = false

func getInstructionData():
	return instructionData
