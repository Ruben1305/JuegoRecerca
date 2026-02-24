extends CanvasLayer

# Máximo número de vidas que puede tener el jugador
@export var max_vidas := 3
# Vidas actuales del jugador, empieza con el máximo
var vidas_actuales := 3

# Array de nodos hijos (los corazones en la barra)
@onready var vidas := get_children()

func _ready() -> void:
	# Actualiza la visibilidad de los corazones según las vidas actuales
	actualizar_vidas()

	# Conecta la señal de cuando el jugador toca un "kill plane"
	Events.kill_plane_touched.connect(_on_kill_plane_touched)

	# Inicia la animación de latido para cada corazón
	for corazon in vidas:
		animar_latido(corazon)


# Función que se llama cuando el jugador toca un "kill plane"
func _on_kill_plane_touched() -> void:
	perder_vida()


# Función para restar una vida y animar el corazón perdido
func perder_vida() -> void:
	if vidas_actuales <= 0:
		return # Si ya no quedan vidas, no hacer nada

	# Obtener el corazón que se va a perder
	var corazon_perdido := vidas[vidas_actuales - 1]
	animar_corazon_perdido(corazon_perdido)

	# Restar una vida y asegurar que esté dentro del rango
	vidas_actuales -= 1
	vidas_actuales = clamp(vidas_actuales, 0, max_vidas)

	# Esperar un pequeño tiempo antes de actualizar la barra
	await get_tree().create_timer(0.3).timeout
	actualizar_vidas()

	# Si ya no quedan vidas, cambiar a la escena de Game Over
	if vidas_actuales == 0:
		game_over()


# Función para mostrar solo los corazones que representan las vidas actuales
func actualizar_vidas() -> void:
	for i in range(vidas.size()):
		vidas[i].visible = i < vidas_actuales

	# Si queda solo un corazón, hacerlo latir más rápido
	if vidas_actuales == 1:
		animar_latido(vidas[0], 0.25) # más rápido
	elif vidas_actuales > 1:
		# Asegurarse que los demás latan a velocidad normal
		for i in range(vidas_actuales):
			animar_latido(vidas[i], 0.5)


# Cambia a la escena de Game Over
func game_over() -> void:
	get_tree().change_scene_to_file("res://escenas/GameOver.tscn")


# Función para animar el latido de un corazón
# Se puede pasar un tiempo de latido opcional (por defecto 0.5s)
func animar_latido(corazon: TextureRect, duracion: float = 0.5) -> void:
	var tween := create_tween()
	tween.set_loops() # animación infinita
	# Aumenta y disminuye el tamaño del corazón para simular latido
	tween.tween_property(corazon, "scale", Vector2(1.05, 1.05), duracion)
	tween.tween_property(corazon, "scale", Vector2(1.0, 1.0), duracion)


# Función para animar un corazón que se pierde
func animar_corazon_perdido(corazon: TextureRect) -> void:
	var tween := create_tween()
	# Hacer que el corazón "salte" un poco
	tween.tween_property(corazon, "scale", Vector2(1.4, 1.4), 0.15)
	# Desvanecer el corazón hasta hacerlo invisible
	tween.tween_property(corazon, "modulate:a", 0.0, 0.2)
