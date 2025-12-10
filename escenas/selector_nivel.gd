extends Control
class_name Level_Selector

func _ready() -> void:
	get_tree().paused = false #Aqui como xiste el menu de pausa pues lo despausamos

func _on_lvl_1_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/LVL'S/game1.tscn")

func _on_lvl_2_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")
