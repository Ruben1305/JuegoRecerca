extends Node3D

@export var move_distance := Vector3(10, 0, 0) # La distancia total del recorrido
@export var speed := 3.0

var pos_a := Vector3.ZERO
var pos_b := Vector3.ZERO
var forward := true
var previous_pos := Vector3.ZERO
var velocity := Vector3.ZERO

func _ready():
	# Definimos los dos extremos basados en la posición inicial
	# La plataforma se moverá entre (Inicio - Distancia/2) y (Inicio + Distancia/2)
	pos_a = global_position - (move_distance / 1.0)
	pos_b = global_position + (move_distance / 1.0)
	
	# Empezamos en un extremo para que el movimiento sea fluido desde el segundo 1
	global_position = pos_a
	previous_pos = global_position

func _physics_process(delta):
	# Elegimos el objetivo dependiendo de la dirección
	var target_pos = pos_b if forward else pos_a
	
	var direction = (target_pos - global_position).normalized()
	var distance = (target_pos - global_position).length()

	# Movimiento suave hacia el objetivo
	if distance > 0.1:
		global_position += direction * speed * delta
	else:
		# Cambiamos de dirección al llegar al extremo
		forward = !forward

	# Cálculo de velocidad para que el personaje se pegue a la plataforma
	velocity = (global_position - previous_pos) / delta
	previous_pos = global_position
