extends Node

var escena_actual_ruta = ""

signal game_paused(paused: bool)

func pause_game(paused: bool) -> void:
	if get_tree().paused == paused:
		return

	get_tree().paused = paused
	game_paused.emit(paused)

func _reintentar():
	if escena_actual_ruta != "":
		get_tree().change_scene_to_file(escena_actual_ruta)
