extends CanvasLayer

func _ready():
	# Esto asegura que el menú esté oculto al arrancar el juego
	visible = false 
	# Si prefieres ocultar solo el ColorRect usa:
	# $ColorRect.visible = false

func _input(event):
	if event.is_action_pressed("Pausar"): 
		actualizar_pausa()

func actualizar_pausa():
	get_tree().paused = !get_tree().paused
	
	# Aquí es donde ocurre la magia: 
	# Si el juego está pausado, visible será true.
	visible = get_tree().paused
	
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_continuar_pressed() -> void:
	actualizar_pausa()

func _on_salir_pressed() -> void:
	get_tree().change_scene_to_file("res://escenas/GUI/Inicio.tscn")
