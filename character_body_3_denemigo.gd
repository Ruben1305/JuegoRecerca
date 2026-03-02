extends CharacterBody3D

@export var velocidad: float = 4.0
@export var rango_ataque: float = 2.0
@export var gravedad: float = 9.8

@onready var detector = $Area3D

var jugador: Node3D = null
var persiguiendo: bool = false


func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravedad * delta
	else:
		velocity.y = 0

	if jugador and persiguiendo:
		var direccion = jugador.global_transform.origin - global_transform.origin
		direccion.y = 0
		var distancia = direccion.length()
		direccion = direccion.normalized()

		look_at(jugador.global_transform.origin, Vector3.UP)

		if distancia > rango_ataque:
			velocity.x = direccion.x * velocidad
			velocity.z = direccion.z * velocidad
		else:
			velocity.x = 0
			velocity.z = 0
			atacar()
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func _on_body_entered(body):
	if body.is_in_group("jugador"):
		jugador = body
		persiguiendo = true


func _on_body_exited(body):
	if body.is_in_group("jugador"):
		persiguiendo = false
		jugador = null


func atacar():
	print("Atacando!")
