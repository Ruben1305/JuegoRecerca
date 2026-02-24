extends Label

func _ready():
	text = "0"
	Puntuacion.puntos_cambiaron.connect(_actualizar_puntos)

func _actualizar_puntos(nuevos_puntos):
	text = "" + str(nuevos_puntos)
