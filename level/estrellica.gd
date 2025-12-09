extends Area3D

@export var rotation_speed: float = 90.0
@export var float_amplitude: float = 0.5
@export var float_speed: float = 2.0

var base_y: float
var time: float = 0.0

func _ready():
	base_y = global_position.y

func _process(delta):
	# Rotación
	rotation_degrees.y += rotation_speed * delta
	# Flotación
	time += delta
	global_position.y = base_y + sin(time * float_speed) * float_amplitude

# Función que dispara al tocar al jugador
func _on_estrellita_body_entered(body: Node) -> void:
	if body.is_in_group("player"):  # el personaje debe estar en el grupo "player"
		queue_free()  # desaparece la estrella
