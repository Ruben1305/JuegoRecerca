extends Control
class_name PauseMenu

@onready var continuar_button = $VBoxContainer/continuar
@onready var salir_button = $VBoxContainer/salir

func _ready() -> void:
	ScenesManager.game_paused.connect(set_pause)
	visible = false

	# Procesar siempre para que funcione mientras el juego está pausado
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children_recursive_safe(self):
		if child is CanvasItem:
			child.process_mode = Node.PROCESS_MODE_ALWAYS

	# Conectar botones
	if continuar_button:
		continuar_button.pressed.connect(_on_continuar_pressed)
	if salir_button:
		salir_button.pressed.connect(_on_salir_pressed)

func set_pause(paused: bool) -> void:
	visible = paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED)

func _on_continuar_pressed() -> void:
	ScenesManager.pause_game(false)

func _on_salir_pressed() -> void:
	ScenesManager.pause_game(false)
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")

# Recursiva para setear process_mode a todos los hijos
func get_children_recursive_safe(node: Node) -> Array:
	var all_children = []
	for child in node.get_children():
		all_children.append(child)
		all_children += get_children_recursive_safe(child)
	return all_children
