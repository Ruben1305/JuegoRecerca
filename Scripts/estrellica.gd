extends Area3D

@export var rotation_speed: float = 90.0
@export var float_amplitude: float = 0.5
@export var float_speed: float = 2.0

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: Node3D = $MeshInstance3D
# Referencia al modelo visual de la estrella

var base_y: float
var time: float = 0.0
var recogida := false

signal estrella_recogida

func _ready():
	add_to_group("estrellas")
	base_y = global_position.y
	body_entered.connect(_on_body_entered)

func _process(delta):
	if recogida:
		return
	# Si ya fue recogida dejamos de animar flotación y rotación

	rotation_degrees.y += rotation_speed * delta
	time += delta
	global_position.y = base_y + sin(time * float_speed) * float_amplitude


func _on_body_entered(body: Node) -> void:

	if recogida:
		return

	if body.is_in_group("player"):

		recogida = true
		collision.disabled = true
		emit_signal("estrella_recogida")

		animacion_recogida()


# ==============================
# ANIMACIÓN DE RECOGIDA
# ==============================

func animacion_recogida():

	var tween = create_tween()

	# 1️⃣ Subir un poco hacia arriba
	tween.tween_property(self, "position:y", position.y + 1.0, 0.3)

	# 2️⃣ Hacerla más pequeña
	tween.parallel().tween_property(self, "scale", Vector3.ZERO, 0.3)

	# 3️⃣ Opcional: Desvanecer (si tiene material con transparencia)
	if mesh.material_override:
		tween.parallel().tween_property(
			mesh.material_override, "albedo_color:a", 0.0, 0.3
		)

	# Cuando termine la animación, borrar
	tween.tween_callback(queue_free)
