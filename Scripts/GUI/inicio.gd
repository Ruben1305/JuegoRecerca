extends Control
class_name Main_Menu

func _ready() -> void:
	get_tree().paused = false  # ✅ Asegura que todo esté despausado al iniciar
	DatabaseManager.guardar_progreso(2, 3)
	print(DatabaseManager)

func _input(event):
	if event.is_action_pressed("Pausar"):
		ScenesManager.pause_game(!get_tree().paused)




func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/GUI/SelectorNivel.tscn")
