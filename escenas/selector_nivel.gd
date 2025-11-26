extends Control
class_name Level_Selector

func _ready() -> void:
	get_tree().paused = false #Aqui como xiste el menu de pausa pues lo despausamos

func _on_lvl_1_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")

func _on_lvl_2_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")

func _on_lvl_3_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")

func _on_lvl_4_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")

func _on_lvl_5_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")

func _on_lvl_6_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/SelectorNivel.tscn")
