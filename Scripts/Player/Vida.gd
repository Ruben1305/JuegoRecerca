extends CanvasLayer

@export var max_vidas := 3
var vidas_actuales := 3

@onready var vidas := get_children()

func _ready() -> void:
	print("Número de corazones: ", vidas.size())
	print("Vidas actuales: ", vidas_actuales)
	actualizar_vidas()
	Events.kill_plane_touched.connect(caer_del_mapa)
	Events.player_damaged.connect(recibir_daño)
	for corazon in vidas:
		animar_latido(corazon)
		# Si no quedan vidas game over
	if vidas_actuales <= 0:
		game_over()

func recibir_daño(cantidad: int) -> void:

	# Comprobamos que el índice es válido antes de animar
	if vidas_actuales > 0 and vidas_actuales <= vidas.size():
		var corazon_perdido := vidas[vidas_actuales - 1]
		animar_corazon_perdido(corazon_perdido)

	vidas_actuales -= cantidad
	vidas_actuales = clamp(vidas_actuales, 0, max_vidas)

	await get_tree().create_timer(0.3).timeout
	actualizar_vidas()

	if vidas_actuales <= 0:
		game_over()

func caer_del_mapa() -> void:
	# Comprobamos que el índice es válido antes de animar
	if vidas_actuales > 0 and vidas_actuales <= vidas.size():
		var corazon_perdido := vidas[vidas_actuales - 1]
		animar_corazon_perdido(corazon_perdido)

	vidas_actuales -= 1
	vidas_actuales = clamp(vidas_actuales, 0, max_vidas)

	await get_tree().create_timer(0.3).timeout
	actualizar_vidas()

	if vidas_actuales == 0:
		game_over()

func actualizar_vidas() -> void:
	for i in range(vidas.size()):
		vidas[i].visible = i < vidas_actuales

	if vidas_actuales == 1:
		animar_latido(vidas[0], 0.25)
	elif vidas_actuales > 1:
		for i in range(vidas_actuales):
			animar_latido(vidas[i], 0.5)

func game_over() -> void:
	get_tree().change_scene_to_file("res://escenas/GUI/GameOver.tscn")

func animar_latido(corazon: TextureRect, duracion: float = 0.5) -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(corazon, "scale", Vector2(1.05, 1.05), duracion)
	tween.tween_property(corazon, "scale", Vector2(1.0, 1.0), duracion)

func animar_corazon_perdido(corazon: TextureRect) -> void:
	var tween := create_tween()
	tween.tween_property(corazon, "scale", Vector2(1.4, 1.4), 0.15)
	tween.tween_property(corazon, "modulate:a", 0.0, 0.2)
