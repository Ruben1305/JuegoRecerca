extends Area3D

@export var rotation_speed: float = 90.0
@export var float_amplitude: float = 0.5
@export var float_speed: float = 2.0

@onready var sonido: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var collision: CollisionShape3D = $CollisionShape3D

var base_y: float
var time: float = 0.0

func _ready():
	base_y = global_position.y
	body_entered.connect(_on_estrellita_body_entered)
	print(sonido)

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
	time += delta
	global_position.y = base_y + sin(time * float_speed) * float_amplitude

func _on_estrellita_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	if sonido:
		sonido.play()

	# Oculta y deshabilita colisión para evitar recoger varias veces
	hide()
	collision.disabled = true

	# Espera a que termine el sonido antes de eliminar el nodo
	if sonido:
		await sonido.finished

	queue_free()
