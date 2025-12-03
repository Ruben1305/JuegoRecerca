extends Control
class_name PauseMenu




func _ready() -> void:
	ScenesManager.game_paused.connect(set_pause)
	
func set_pause():
	self.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)



func _on_coninuar_pressed() -> void:
	self.visible = false
	ScenesManager.pause_game(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")
