extends Control

func _ready():
	# Ocultamos el menú al inicio
	visible = false
	# Permitimos que este nodo siga procesando incluso cuando el juego está pausado
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func toggle_pause():
	var paused := !get_tree().paused
	get_tree().paused = paused
	
	# Mostramos/ocultamos este menú (PauseMenu entero)
	visible = paused

	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE  # Cursor visible en menú
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Cursor capturado en juego

func _unhandled_input(event):
	if event.is_action_pressed("Pausar"):
		toggle_pause()

func _on_continuar_pressed() -> void:
	toggle_pause()  # Despausa

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")
