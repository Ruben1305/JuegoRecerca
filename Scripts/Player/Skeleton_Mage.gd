extends CharacterBody3D

@export var speed: float = 3.0
@export var gravity: float = 9.8
@export var attack_damage: int = 1
@export var attack_cooldown: float = 2.0
@export var attack_range: float = 1.5
@export var rotation_speed: float = 5.0

@onready var anim_player: AnimationPlayer = $Skeleton_Mage/AnimationPlayer
@onready var detection_area: Area3D = $DetectionArea

const ANIM_IDLE   = "Animation_Items/Idle_A"
const ANIM_WALK   = "AnimationMovement/Walking_B"
const ANIM_ATTACK = "Animation_Items/Throw"  # Cámbialo cuando tengas la animación

enum State { PATROL, ATTACK }
var current_state: State = State.PATROL
var move_direction: Vector3 = Vector3.ZERO
var player: Node = null
var can_attack: bool = true
var is_attacking: bool = false

func _ready() -> void:
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	_play_anim(ANIM_IDLE)
	_start_random_movement()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	match current_state:
		State.PATROL:
			_patrol(delta)
		State.ATTACK:
			_attack_behavior(delta)

	move_and_slide()

# ─────────────────────────────────────────
#  ANIMACIONES
# ─────────────────────────────────────────
func _play_anim(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)


# ─────────────────────────────────────────
#  PATRULLA
# ─────────────────────────────────────────
func _patrol(delta: float) -> void:
	if is_on_wall():
		_pick_random_direction()

	velocity.x = speed * move_direction.x
	velocity.z = speed * move_direction.z

	if move_direction == Vector3.ZERO:
		_play_anim(ANIM_IDLE)
	else:
		_play_anim(ANIM_WALK)

	if move_direction != Vector3.ZERO:
		var target_pos = global_position + move_direction
		target_pos.y = global_position.y
		var target_rotation = global_position.direction_to(target_pos)
		var new_basis = basis.slerp(
			Basis.looking_at(-target_rotation, Vector3.UP),
			rotation_speed * delta
		)
		basis = new_basis

# ─────────────────────────────────────────
#  MOVIMIENTO RANDOM
# ─────────────────────────────────────────
func _start_random_movement() -> void:
	while true:
		if current_state == State.PATROL:
			_pick_random_direction()
		var wait_time = randf_range(1.0, 3.0)
		await get_tree().create_timer(wait_time).timeout

func _pick_random_direction() -> void:
	var directions = [
		Vector3(1, 0, 0),
		Vector3(-1, 0, 0),
		Vector3(0, 0, 1),
		Vector3(0, 0, -1),
		Vector3(1, 0, 1).normalized(),
		Vector3(-1, 0, 1).normalized(),
		Vector3(1, 0, -1).normalized(),
		Vector3(-1, 0, -1).normalized(),
		Vector3.ZERO
	]
	move_direction = directions[randi() % directions.size()]

# ─────────────────────────────────────────
#  ATAQUE
# ─────────────────────────────────────────
func _attack_behavior(delta: float) -> void:
	if player == null:
		current_state = State.PATROL
		return

	var diff = player.global_position - global_position
	diff.y = 0.0
	var dist = diff.length()


	if diff != Vector3.ZERO:
		var new_basis = basis.slerp(
			Basis.looking_at(-diff.normalized(), Vector3.UP),
			rotation_speed * delta
		)
		basis = new_basis

	if dist > attack_range:
		_play_anim(ANIM_WALK)
		velocity.x = diff.normalized().x * speed
		velocity.z = diff.normalized().z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
		if can_attack and not is_attacking:
			_do_attack()
			_play_anim(ANIM_ATTACK)

func _do_attack() -> void:
	can_attack = false
	is_attacking = true
	_play_anim(ANIM_IDLE)
	

	# Emitimos la señal con la cantidad de daño
	Events.player_damaged.emit(attack_damage)

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	_play_anim(ANIM_ATTACK)


# ─────────────────────────────────────────
#  DETECCIÓN DEL JUGADOR
# ─────────────────────────────────────────
func _on_player_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.ATTACK


func _on_player_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL
