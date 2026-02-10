extends Node

var puntos := 0

signal puntos_cambiaron(nuevos_puntos)

func sumar_punto():
	puntos += 1
	emit_signal("puntos_cambiaron", puntos)
