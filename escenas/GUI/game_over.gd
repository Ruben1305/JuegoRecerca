extends Control

func _mouse ():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_reintentar_pressed() -> void:
	ScenesManager.reintentar()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED



func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/GUI/Inicio.tscn")
