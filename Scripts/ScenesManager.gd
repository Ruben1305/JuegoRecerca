extends Node

signal game_paused

func pause_game(pause: bool):
	get_tree().paused = pause
	
	if pause:
		game_paused.emit()
	#if pause:
		#var canvas: CanvasLayer = get_tree().current_scene.get_node("CanvasLayer")
		#var pause_menu: PauseMenu = canvas.get_node("PauseMenu")
		
		#pause_menu.visible = true
