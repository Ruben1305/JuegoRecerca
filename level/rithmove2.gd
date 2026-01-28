extends Node3D

@export var move_distance := Vector3(15, 0, 0)
@export var speed := 3.0

var start_pos := Vector3.ZERO
var forward := true
var previous_pos := Vector3.ZERO

# Velocidad de la plataforma
var velocity := Vector3.ZERO

func _ready():
	start_pos = global_position
	previous_pos = global_position

func _physics_process(delta):
	var target_pos = start_pos + move_distance if forward else start_pos
	var direction = (target_pos - global_position).normalized()
	var distance = (target_pos - global_position).length()

	if distance > 0.01:
		global_position += direction * speed * delta
	else:
		forward = not forward

	# Calculamos la velocidad de la plataforma este frame
	velocity = (global_position - previous_pos) / delta
	previous_pos = global_position
