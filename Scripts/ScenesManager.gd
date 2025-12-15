extends Node

signal game_paused(paused: bool)

func pause_game(paused: bool) -> void:
	if get_tree().paused == paused:
		return

	get_tree().paused = paused
	game_paused.emit(paused)
