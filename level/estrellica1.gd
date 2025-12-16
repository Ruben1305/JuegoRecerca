extends Area3D   # IMPORTANTE: Area3D, no CollisionShape3D

@export var rotation_speed: float = 90.0
@export var float_amplitude: float = 0.5
@export var float_speed: float = 2.0

var base_y: float
var time: float = 0.0

func _ready():
	base_y = global_position.y
	body_entered.connect(_on_estrellita_body_entered)

func _process(delta):
	rotation_degrees.y += rotation_speed * delta
	time += delta
	global_position.y = base_y + sin(time * float_speed) * float_amplitude

func _on_estrellita_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		queue_free()
