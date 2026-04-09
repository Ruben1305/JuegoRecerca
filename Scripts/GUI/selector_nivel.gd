extends Control
class_name Level_Selector

func _ready() -> void:
	get_tree().paused = false

func _on_lvl_1_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/LVLS/gamelv1.tscn")

func _on_lvl_2_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/LVLS/gamelv2.tscn")

func _on_lvl_3_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/LVLS/gamelv3.tscn")

func _on_lvl_4_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/LVLS/gamelv4.tscn")

#func _on_lvl_5_pressed() -> void:
#	get_tree().change_scene_to_file("res://escenas/LVLS/gamelv5.tscn")
