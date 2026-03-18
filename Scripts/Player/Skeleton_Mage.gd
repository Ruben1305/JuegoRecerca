extends CharacterBody3D

@export var velocidad: float = 3.0
@export var gravedad: float = 9.8
@export var rango_ataque: float = 2.0
@export var tiempo_entre_ataques: float = 1.0
@export var tiempo_cambiar_direccion: float = 3.0

@onready var detector = $Area3D
@onready var ray_suelo = $RayCast3D

var direccion_mov: Vector3 = Vector3.ZERO
var tiempo_mov: float = 0
var jugador: Node3D = null
var tiempo_ataque: float = 0

func _ready():
	randomize()
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	elegir_direccion_random()

func _physics_process(delta):

	# gravedad
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0

	tiempo_mov += delta
	tiempo_ataque += delta

	# dirección
	if jugador:
		var dir = jugador.global_position - global_position
		dir.y = 0
		direccion_mov = dir.normalized()

		var distancia = global_position.distance_to(jugador.global_position)

		if distancia <= rango_ataque and tiempo_ataque >= tiempo_entre_ataques:
			if jugador.has_method("recibir_danio"):
				jugador.recibir_danio(1)
			tiempo_ataque = 0

	else:
		if tiempo_mov > tiempo_cambiar_direccion:
			elegir_direccion_random()
			tiempo_mov = 0


	# girar hacia la dirección
	if direccion_mov.length() > 0.1:
		rotation.y = atan2(direccion_mov.x, direccion_mov.z)


	# DETECCIÓN DE BORDE
	if ray_suelo.is_colliding():

		velocity.x = sin(rotation.y) * velocidad
		velocity.z = cos(rotation.y) * velocidad

	else:

		# dar la vuelta 180° en vez de dirección random
		rotation.y += PI

		velocity.x = 0
		velocity.z = 0


	move_and_slide()


func elegir_direccion_random():
	direccion_mov = Vector3(randf_range(-1,1),0,randf_range(-1,1)).normalized()


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		jugador = body


func _on_body_exited(body):
	if body.is_in_group("jugador"):
		jugador = null
