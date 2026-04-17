extends Node


var escena_actual_ruta = ""

func reintentar():
	if escena_actual_ruta != "":
		get_tree().change_scene(escena_actual_ruta)
