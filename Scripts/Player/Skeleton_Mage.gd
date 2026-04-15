extends CharacterBody3D

@export var speed: float = 3.0
@export var gravity: float = 9.8
@export var attack_damage: int = 1
@export var attack_cooldown: float = 4.0
@export var attack_range: float = 1.5
@export var rotation_speed: float = 5.0
@export var max_health: int = 3
var current_health: int = 3

@onready var anim_player: AnimationPlayer = $Skeleton_Mage/AnimationPlayer
@onready var detection_area: Area3D = $DetectionArea

const ANIM_IDLE = "Animation_Items/Idle_A"
const ANIM_WALK = "AnimationMovement/Walking_B"

enum State { PATROL, ATTACK }
var current_state: State = State.PATROL
var move_direction: Vector3 = Vector3.ZERO
var player: Node = null
var can_attack: bool = true
var is_attacking: bool = false

var health_bar_mesh: MeshInstance3D
var bg_mesh: MeshInstance3D
var hide_timer: float = 0.0
const HIDE_DELAY: float = 2.0

func _ready() -> void:
	add_to_group("enemigo")
	current_health = max_health
	detection_area.body_entered.connect(_on_player_entered)
	detection_area.body_exited.connect(_on_player_exited)
	_play_anim(ANIM_IDLE)
	_start_random_movement()
	_create_health_bar()

func _create_health_bar() -> void:
	bg_mesh = MeshInstance3D.new()
	var bg_quad = QuadMesh.new()
	bg_quad.size = Vector2(1.0, 0.1)
	bg_mesh.mesh = bg_quad
	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = Color(0.2, 0.2, 0.2)
	bg_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bg_mesh.material_override = bg_material
	bg_mesh.position = Vector3(0, 2.5, 0)
	bg_mesh.visible = false
	add_child(bg_mesh)

	health_bar_mesh = MeshInstance3D.new()
	var bar_quad = QuadMesh.new()
	bar_quad.size = Vector2(1.0, 0.08)
	health_bar_mesh.mesh = bar_quad
	var bar_material = StandardMaterial3D.new()
	bar_material.albedo_color = Color(0.0, 1.0, 0.0)
	bar_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	health_bar_mesh.material_override = bar_material
	health_bar_mesh.position = Vector3(0, 2.5, 0.001)
	health_bar_mesh.visible = false
	add_child(health_bar_mesh)

func _update_health_bar() -> void:
	if health_bar_mesh == null:
		return

	var percent = float(current_health) / float(max_health)

	var quad = health_bar_mesh.mesh as QuadMesh
	quad.size = Vector2(percent, 0.08)
	health_bar_mesh.position.x = (percent - 1.0) / 2.0

	var mat = health_bar_mesh.material_override as StandardMaterial3D
	if percent > 0.6:
		mat.albedo_color = Color(0.0, 1.0, 0.0)
	elif percent > 0.3:
		mat.albedo_color = Color(1.0, 0.5, 0.0)
	else:
		mat.albedo_color = Color(1.0, 0.0, 0.0)

	health_bar_mesh.visible = true
	bg_mesh.visible = true
	hide_timer = HIDE_DELAY

func take_damage(cantidad: int) -> void:
	print("Enemigo recibió daño: ", cantidad)
	current_health -= cantidad
	current_health = clamp(current_health, 0, max_health)
	_update_health_bar()
	if current_health <= 0:
		_die()

func _die() -> void:
	queue_free()

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

	if health_bar_mesh != null and health_bar_mesh.visible:
		hide_timer -= delta
		if hide_timer <= 0:
			health_bar_mesh.visible = false
			bg_mesh.visible = false

	if health_bar_mesh != null and health_bar_mesh.visible:
		var camera = get_viewport().get_camera_3d()
		if camera:
			health_bar_mesh.look_at(camera.global_position, Vector3.UP)
			bg_mesh.look_at(camera.global_position, Vector3.UP)

	move_and_slide()

func _play_anim(anim_name: String) -> void:
	if anim_player.current_animation != anim_name:
		anim_player.play(anim_name)

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
		elif not is_attacking:
			_play_anim(ANIM_IDLE)

func _do_attack() -> void:
	can_attack = false
	is_attacking = true
	_play_anim(ANIM_IDLE)
	Events.player_damaged.emit(attack_damage)
	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_player_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player = body
		current_state = State.ATTACK

func _on_player_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player = null
		current_state = State.PATROL
