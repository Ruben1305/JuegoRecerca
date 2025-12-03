extends Button
class_name CustomButton


func _on_pressed() -> void:
	get_tree().paused = false


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")
