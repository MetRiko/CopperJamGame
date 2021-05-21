extends Control

var nodeData = null

func setNodeData(nodeData, frameId):
	self.nodeData = nodeData
	if nodeData != null:
		$Sprite.frame = frameId
	else:
		push_error("nodeData == null")
