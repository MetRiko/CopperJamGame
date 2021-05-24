extends Button

var instructionData = null

func setInstructionData(instructionData):
	if instructionData != null:
		self.instructionData = instructionData
#		text = instructionData.name
		show()
		$Sprite.frame = instructionData.frameId
	else:
		hide()


func getInstructionData():
	return instructionData
