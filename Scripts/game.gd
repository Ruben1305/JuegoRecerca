extends Node

var puntuacion = 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		get_viewport().mode = (
			Window.MODE_FULLSCREEN if
			get_viewport().mode != Window.MODE_FULLSCREEN else
			Window.MODE_WINDOWED
		)
		

func  incrementa_un_punto():
	puntuacion += 1

func morir():
	ScenesManager.escena_actual_ruta = get_tree().current_scene.filename
	get_tree().change_scene("res://Escenas/GameOver.tscn")
