extends CanvasLayer

@onready var label_numero = $ContadorEstrellas

var estrellas: int = 0
var escala_original: Vector2

func _ready():
	label_numero.text = str(estrellas)

	# Guardamos la escala original para volver después
	escala_original = label_numero.scale

	# Conectar todas las estrellas
	for estrella in get_tree().get_nodes_in_group("estrellas"):
		estrella.estrella_recogida.connect(_on_estrella_recogida)


func _on_estrella_recogida():
	estrellas += 1
	label_numero.text = str(estrellas)

	animar_contador()


# ==============================
# ANIMACIÓN DEL CONTADOR
# ==============================

func animar_contador():

	var tween = create_tween()

	# 1️⃣ Agrandar
	tween.tween_property(
		label_numero,
		"scale",
		escala_original * 1.4,
		0.1
	)

	# 2️⃣ Volver al tamaño normal (rebote suave)
	tween.tween_property(
		label_numero,
		"scale",
		escala_original,
		0.15
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
