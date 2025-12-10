extends Control
class_name Main_Menu


func _ready() -> void:
	get_tree().paused = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_game_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")
