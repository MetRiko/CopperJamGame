extends Control

onready var beatController = Game.beatController
onready var gui = Game.gui
onready var menu = Game.menu
var isPaused = true



func _unhandled_input(event):
	if event.is_action_pressed("pause") && beatController.isPaused() == false && menu.visible == false:
		$".".visible = true
		beatController.setPause(true)
	elif event.is_action_pressed("pause") && beatController.isPaused() == true:
		$".".visible = false
		beatController.setPause(false)

#get_tree().quit()


func _ready():
	var numOfPauseButton = 0
	for button in get_node("VBoxContainer").get_children():
		if numOfPauseButton == 0:
			button.get_child(0).text = "Resume"
		elif numOfPauseButton == 1:
			button.get_child(0).text = "Restart"
		elif numOfPauseButton == 2:
			button.get_child(0).text = "Title screen"
		
		button.connect("pressed", self, "pause_menu_button_pressed", [numOfPauseButton])
		
		
		numOfPauseButton += 1
		
		

func pause_menu_button_pressed(numOfButton):
	if numOfButton == 0:
		print("resuming")
		resume()
	elif numOfButton == 1:
		print("restarting")
		Game.menu.restart()
	elif numOfButton == 2:
		print("exiting to menu")
		exit_to_menu()
		
func resume():
	get_node(".").visible = false
	beatController.setPause(false)

func exit_to_menu():
	menu.visible = true
	gui.visible = false
	get_node(".").visible = false


