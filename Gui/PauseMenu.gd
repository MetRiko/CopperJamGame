extends Control
var isPaused = false


func _unhandled_input(event):
	if event.is_action_pressed("pause") && isPaused == false:
		$".".visible = true
		isPaused = true
	elif event.is_action_pressed("pause") && isPaused == true:
		$".".visible = false
		isPaused = false

#get_tree().quit()


func _ready():
	var numOfPauseButton = 0
	for button in get_node("VBoxContainer").get_children():
		button.connect("pressed", self, "pause_menu_button_pressed", [numOfPauseButton])
		numOfPauseButton += 1
		

func pause_menu_button_pressed(numOfButton):
	if numOfButton == 0:
		print("resuming")
		resume()
	elif numOfButton == 1:
		print("displaying the settings")
		Game.menu.display_settings()
	elif numOfButton == 2:
		print("exiting to menu")
		exit_to_menu()
		
func resume():
	pass

func exit_to_menu():
	pass
