extends Area3D


func _ready() -> void:
	body_entered.connect(func (_body_that_entered: PhysicsBody3D) -> void:
		await get_tree().process_frame
		Events.kill_plane_touched.emit()
	)


func _on_estrellica_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		queue_free()

		
	
	
