extends Area3D

@export var rotation_speed: float = 90.0
@export var float_amplitude: float = 0.5
@export var float_speed: float = 2.0

@onready var collision: CollisionShape3D = $CollisionShape3D

var base_y: float
var time: float = 0.0
var recogida := false


# Contador de estrellas
var estrellas_actuales := 0

# Señal que se emite al recoger una estrella
signal estrella_recogida

# Función para sumar un punto
func sumar_punto():
	estrellas_actuales += 1
	emit_signal("estrella_recogida")


func _ready():
	base_y = global_position.y
	body_entered.connect(_on_estrellita_body_entered)

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
	time += delta
	global_position.y = base_y + sin(time * float_speed) * float_amplitude

func _on_estrellita_body_entered(body: Node) -> void:
	if recogida:
		return

	if body.is_in_group("player"):
		recogida = true
		Puntuacion.sumar_punto()

		hide()
		collision.disabled = true

		queue_free()
