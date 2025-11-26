extends CharacterBody3D

# ——— CONFIGURACIÓN ———
@export_group("Movement")
@export var speed: float = 5.0
@export var acceleration: float = 10.0     # Aceleración suave
@export var jump_velocity: float = 4.5
@export var rotation_speed: float = 8.0    # Velocidad de giro (radianes/segundo)

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.2
@export var camera_distance: float = 4.0
@export var camera_height: float = 1.8
@export var tilt_min: float = -0.8      # -45°
@export var tilt_max: float = 1.0       # +57°

# ——— VARIABLES INTERNAS ———
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _camera_input := Vector2.ZERO
var _camera_pivot: Node3D
var _camera: Camera3D
var _model: Node3D


# ——— INICIALIZACIÓN ———
func _ready() -> void:
	# Buscamos los nodos por nombre (usa % para enlazar por nombre)
	_camera_pivot = %CameraPivot
	_camera = %Camera3D
	_model = %Model if has_node("%Model") else null

	# Configuramos la cámara
	_camera.current = true
	_update_camera_position()

	# 🖱️ Capturar el ratón al iniciar el juego
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ——— CONTROL DE RATÓN ———
func _input(event: InputEvent) -> void:
	# Capturar/ liberar el cursor con clic izquierdo
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_CAPTURED 
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE 
			else Input.MOUSE_MODE_VISIBLE
		)
	
	# Capturar movimiento del ratón (solo cuando está capturado)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_input.x = -event.relative.x * mouse_sensitivity
		_camera_input.y = -event.relative.y * mouse_sensitivity


# ——— FÍSICA Y MOVIMIENTO ———
func _physics_process(delta: float) -> void:
	
	# 1. ACTUALIZAR CÁMARA...
	_camera_pivot.rotation.x += _camera_input.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_min, tilt_max)
	rotation.y += _camera_input.x * delta
	_camera_input = Vector2.ZERO
	_update_camera_position()

	# 2. GRAVEDAD 
	if not is_on_floor():
		velocity.y -= _gravity * delta 
	else:
		velocity.y = move_toward(velocity.y, 0, 15.0)

	# 3. SALTO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity  # positivo es decir va para arriba

	# 4. MOVIMIENTO RELATIVO A LA CÁMARA
	var input_dir := Input.get_vector("Izquierda", "Derecha", "Atras", "Alante")
	
	# Dirección adelante/izquierda según la CÁMARA
	var cam_forward := -_camera.global_basis.z  # En Godot, la cámara mira -Z
	var cam_right := _camera.global_basis.x
	var move_dir := (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()
	
	# Aplicar aceleración suave
	var target_velocity := Vector3(move_dir.x * speed, velocity.y, move_dir.z * speed)
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# 5. ROTACIÓN SUAVE DEL MODELO (si existe)
	if _model and move_dir.length() > 0.1:
		var target_angle := Vector3.FORWARD.signed_angle_to(move_dir, Vector3.UP)
		_model.rotation.y = lerp_angle(_model.rotation.y, target_angle, rotation_speed * delta)

	# 6. MOVER
	move_and_slide()


# ——— UTILIDADES ———
func _update_camera_position() -> void:
	if not _camera_pivot or not _camera:
		return
	# Posicionar cámara detrás y arriba del jugador
	_camera.global_position = global_position + Vector3.UP * camera_height
	_camera.global_position -= _camera.global_basis.z * camera_distance
