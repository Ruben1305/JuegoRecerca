extends CharacterBody3D

@export var velocidad: float = 4.0
@export var gravedad: float = 9.8
@export var rango_ataque: float = 2.5
@export var tiempo_entre_ataques: float = 1.0
@export var radio_patrulla: float = 6.0

@onready var detector = $Area3D
@onready var agente = $NavigationAgent3D

var jugador: Node3D = null
var persiguiendo = false
var tiempo_ataque = 0.0

var destino_patrulla: Vector3
var tiempo_patrulla = 0.0


func _ready():
	randomize()

	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

	elegir_destino_patrulla()


func _physics_process(delta):

	# gravedad
	if !is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0


	tiempo_ataque += delta


	# PERSEGUIR
	if jugador and persiguiendo:
		agente.target_position = jugador.global_transform.origin

	else:
		# PATRULLA
		tiempo_patrulla += delta

		if tiempo_patrulla > 3:
			elegir_destino_patrulla()
			tiempo_patrulla = 0

		agente.target_position = destino_patrulla


	# MOVIMIENTO CON PATHFINDING
	var next_position = agente.get_next_path_position()

	var direccion = next_position - global_transform.origin
	direccion.y = 0

	if direccion.length() > 0.1:

		direccion = direccion.normalized()

		velocity.x = direccion.x * velocidad
		velocity.z = direccion.z * velocidad

		look_at(global_transform.origin + direccion, Vector3.UP)

	else:

		velocity.x = 0
		velocity.z = 0


	# ATAQUE
	if jugador and persiguiendo:

		var distancia = global_transform.origin.distance_to(jugador.global_transform.origin)

		if distancia < rango_ataque:

			if tiempo_ataque >= tiempo_entre_ataques:

				atacar()
				tiempo_ataque = 0


	move_and_slide()


func elegir_destino_patrulla():

	var x = randf_range(-radio_patrulla, radio_patrulla)
	var z = randf_range(-radio_patrulla, radio_patrulla)

	destino_patrulla = global_transform.origin + Vector3(x,0,z)


func atacar():
	print("Atacando")


func _on_body_entered(body):

	if body.is_in_group("jugador"):
		jugador = body
		persiguiendo = true


func _on_body_exited(body):

	if body.is_in_group("jugador"):
		persiguiendo = false
		jugador = null
