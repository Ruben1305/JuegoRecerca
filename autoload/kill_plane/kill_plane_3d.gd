extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: PhysicsBody3D) -> void:
	if body.is_in_group("player"):
		await get_tree().process_frame
		Events.kill_plane_touched.emit()

	
	
