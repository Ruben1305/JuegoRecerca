extends CharacterBody3D

# ================================
# --- PARÁMETROS DE MOVIMIENTO ---
# ================================
@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var jump_impulse := 12.0
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0

# ================================
# --- PARÁMETROS DE CÁMARA ---
# ================================
@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

# ================================
# --- VARIABLES INTERNAS ---
# ================================
var _gravity := -30.0
var _was_on_floor_last_frame := true
var _camera_input_direction := Vector2.ZERO
var _last_input_direction := Vector3.BACK
var _start_position := Vector3.ZERO
var max_jumps := 1   # Número de saltos permitidos (1 = doble salto)
var jumps_left := max_jumps 
var can_jump := true        # Para evitar rebotes de tecla
# ================================
# --- REFERENCIAS A NODOS ---
# ================================
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: SophiaSkin = %SophiaSkin
@onready var _landing_sound: AudioStreamPlayer3D = %LandingSound
@onready var _jump_sound: AudioStreamPlayer3D = %JumpSound
@onready var _dust_particles: GPUParticles3D = %DustParticles

# ================================
# --- CONFIGURACIÓN INICIAL ---
# ================================
func _ready():
	_start_position = global_position

	# Reinicio si toca kill plane
	Events.kill_plane_touched.connect(func():
		global_position = _start_position
		velocity = Vector3.ZERO
		jumps_left = max_jumps # Resetear los saltos
		_skin.idle()
		set_physics_process(true)
	)

	# Fin de nivel
	Events.flag_reached.connect(func():
		set_physics_process(false)
		_skin.idle()
		_dust_particles.emitting = false
	)

# ================================
# --- ENTRADAS DEL JUGADOR ---
# ================================
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausar"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file("res://escenas/pause_menu.tscn")
	elif event.is_action_pressed("ClicIzq"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction.x = -event.relative.x * mouse_sensitivity
		_camera_input_direction.y = -event.relative.y * mouse_sensitivity

# ================================
# --- FÍSICAS Y MOVIMIENTO ---
# ================================
func _physics_process(delta: float) -> void:

	# -------- ROTACIÓN DE CÁMARA --------
	_camera_pivot.rotation.x += _camera_input_direction.y * delta
	_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x, tilt_lower_limit, tilt_upper_limit)
	_camera_pivot.rotation.y += _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO

	# -------- INPUT DE MOVIMIENTO --------
	var raw_input = Input.get_vector("Izquierda", "Derecha", "Alante", "Atras", 0.4)
	var forward = _camera.global_basis.z
	var right = _camera.global_basis.x
	var move_direction = (forward * raw_input.y + right * raw_input.x)
	move_direction.y = 0
	move_direction = move_direction.normalized()

	if move_direction.length() > 0.2:
		_last_input_direction = move_direction

	var target_angle = Vector3.BACK.signed_angle_to(_last_input_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# -------- VELOCIDAD Y GRAVEDAD CORREGIDA --------
	if is_on_floor():
		velocity.y = 0  # Reseteamos al tocar suelo

	# Movimiento horizontal
	var horizontal_velocity = velocity
	horizontal_velocity.y = 0
	horizontal_velocity = horizontal_velocity.move_toward(move_direction * move_speed, acceleration * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	# Aplicar gravedad
	velocity.y += _gravity * delta


	# ======== SALTO ========
	if Input.is_action_just_pressed("Saltar") and can_jump and jumps_left > 0:
		velocity.y = jump_impulse
		jumps_left -= 1
		can_jump = false
	if jumps_left == max_jumps - 1:
		_skin.jump()         # primer salto
	else:
		_skin.jump()  # segundo salto
	_jump_sound.play()

	# Reset de saltos y flag al tocar el suelo
	if is_on_floor():
		jumps_left = max_jumps
		can_jump = true

	# Reset del flag cuando se suelta el botón
	if not Input.is_action_pressed("Saltar"):
		can_jump = true



	# ==================================================
	# === MOVER AL JUGADOR CON PLATAFORMA MÓVIL (Godot 4) ===
	# ==================================================
	var platform: Node3D = null

	if is_on_floor():
		# Obtenemos la última colisión usada por move_and_slide()
		var collision = get_last_slide_collision()
		if collision:
			var collider = collision.get_collider()
			# Comprobamos si el collider tiene propiedad "velocity"
			if collider and "velocity" in collider:
				platform = collider

	# Sumamos solo la velocidad horizontal de la plataforma
	if platform:
		global_position.x += platform.velocity.x * delta
		global_position.z += platform.velocity.z * delta

	# -------- ANIMACIONES Y PARTICULAS --------
	var ground_speed = Vector2(velocity.x, velocity.z).length()

	if not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		if ground_speed > 0:
			_skin.move()
		else:
			_skin.idle()

	_dust_particles.emitting = is_on_floor() and ground_speed > 0

	if is_on_floor() and not _was_on_floor_last_frame:
		_landing_sound.play()

	_was_on_floor_last_frame = is_on_floor()

	# -------- MOVER PERSONAJE --------
	move_and_slide()
