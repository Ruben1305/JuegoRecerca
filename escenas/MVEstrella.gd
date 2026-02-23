extends CanvasLayer

@onready var contador := $Contador

var tween: Tween

func _ready() -> void:
	# Mostrar valor inicial
	contador.text = str(Puntuacion.estrellas_actuales)

	# Ajustar pivot para el pop
	await get_tree().process_frame
	contador.pivot_offset = contador.size / 2

	# 🔑 Conectar la señal del singleton
	Puntuacion.estrella_recogida.connect(_on_estrella_recogida)


func _on_estrella_recogida() -> void:
	# Actualizar número
	contador.text = str(Puntuacion.estrellas_actuales)

	# Animar
	animar_contador()


func animar_contador() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(contador, "scale", Vector2(1.4, 1.4), 0.12)
	tween.tween_property(contador, "scale", Vector2(1.0, 1.0), 0.12)
