extends CharacterBody3D

@export_group("Movement")
@export var move_speed := 8.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0
@export var jump_impulse := 12.0
@export var max_jumps := 2

@export_group("Wall Slide / Gravity")
@export var gravity := -30.0
@export var wall_slide_gravity := -6.0
@export var max_wall_slide_speed := -3.0

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export var tilt_upper_limit := PI / 3.0
@export var tilt_lower_limit := -PI / 8.0

# --------------------
# Internas
# --------------------
var jumps_left := max_jumps
var can_jump := true
var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK
var is_wall_sliding := false
var _start_position := Vector3.ZERO
var was_on_floor := false

# --------------------
# EDGE GRAB
# --------------------


var is_ledge_grabbing := false
var ledge_normal := Vector3.ZERO
var ledge_point := Vector3.ZERO

# --------------------
# Referencias
# --------------------
@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _camera: Camera3D = %Camera3D
@onready var _skin: SophiaSkin = %SophiaSkin
@export var ledge_snap_distance := 0.35
@export var ledge_jump_vertical := 6.0



# --------------------
# Ready
# --------------------
func _ready() -> void:
	_start_position = global_position

	Events.kill_plane_touched.connect(func():
		global_position = _start_position
		velocity = Vector3.ZERO
		jumps_left = max_jumps
		_skin.idle()
		set_physics_process(true)
	)

# --------------------
# Input
# --------------------
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausar"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("ClicIzq"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_camera_input_direction = event.relative * mouse_sensitivity

# --------------------
# Physics
# --------------------

func _physics_process(delta: float) -> void:
	# --- Cámara ---
	_camera_pivot.rotation.x = clamp(
		_camera_pivot.rotation.x + _camera_input_direction.y * delta,
		tilt_lower_limit,
		tilt_upper_limit
	)
	_camera_pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
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

	# --- Input Movimiento ---
	var raw_input := Input.get_vector("Izquierda", "Derecha", "Atras", "Alante")
	var forward := -_camera.global_basis.z
	var right := _camera.global_basis.x
	var move_direction := (forward * raw_input.y + right * raw_input.x)
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction

	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	_skin.global_rotation.y = lerp_angle(_skin.rotation.y, target_angle, rotation_speed * delta)

	# --- Movimiento horizontal ---
	velocity.x = lerp(velocity.x, move_direction.x * move_speed, acceleration * delta)
	velocity.z = lerp(velocity.z, move_direction.z * move_speed, acceleration * delta)

	# --- Wall slide detection ---
	is_wall_sliding = false
	if not is_on_floor() and velocity.y < 0:
		for i in range(get_slide_collision_count()):
			var col = get_slide_collision(i)
			var normal := col.get_normal()
			if abs(normal.y) < 0.2:
				is_wall_sliding = true
				break

	# --- Gravedad ---
	if is_wall_sliding:
		velocity.y += wall_slide_gravity * delta
		velocity.y = max(velocity.y, max_wall_slide_speed)
	else:
		velocity.y += gravity * delta

# --- Reset saltos en suelo o wall slide ---
	if (is_on_floor() or is_wall_sliding) and not was_on_floor:
		jumps_left = max_jumps
	# --- Salto normal ---
	if Input.is_action_just_pressed("Saltar") and jumps_left > 0:
		velocity.y = jump_impulse
		jumps_left -= 1
		_skin.jump()
	was_on_floor = is_on_floor()
	
	move_and_slide()

	# --- Animaciones ---
	if is_wall_sliding:
		_skin.wall_slide()
	elif not is_on_floor() and velocity.y < 0:
		_skin.fall()
	elif is_on_floor():
		var ground_speed := Vector3(velocity.x, 0, velocity.z).length()
		if ground_speed > 0.1:
			_skin.move()
		else:
			_skin.idle()



	
